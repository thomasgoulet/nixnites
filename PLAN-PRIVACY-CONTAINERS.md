# PLAN: Move searx and blocky into isolated NixOS containers

## Problem Statement

Searx (a local meta-search engine) and blocky (a DNS ad-blocking resolver) run as native host services in the `privacy` aspect. I want them separated from the host, with network isolation, so that only the ports each service needs are exposed and nothing is reachable from my LAN. I also want to reach searx through a friendly local name instead of `localhost:8888`.

The hosts are a WSL2 machine (`oric`, mirrored networking mode, Windows browser used via `wsl-open`) and a native NixOS machine (`yousuke`, NetworkManager). Eventually the aspect must work on both. Nested containers with private networking and NAT on WSL are unproven, so feasibility must be verified before anything else is built.

## Solution

Run searx and blocky as declarative, auto-started NixOS containers, each with a private network (fixed IPs in 10.233.0.0/16), a one-port inbound firewall, and egress limited to what the service needs.

- Searx is reached at `http://searx.home.arpa:8888`. A loopback-only TCP forwarder on the host relays to the container, and a hosts entry maps the name to 127.0.0.1. On WSL the Windows hosts file needs the same entry added by hand.
- Blocky becomes the host's primary resolver at its container IP, with a public fallback resolver.
- Work is split into four steps. **Step 0 is a feasibility spike that gates everything else.** If it fails, stop and revise this spec before proceeding.

## Acceptance Criteria

### Step 0: spike (gates all other steps)

1. A throwaway test container must be defined with a private network, fixed host and container IPs on a spare /24 in 10.233.0.0/16, and NAT, so that feasibility of nested containers on WSL can be proven cheaply.
2. The spike must verify the test container boots under WSL (systemd, cgroup v2, veth interfaces created) so that we know nspawn works there.
3. The spike must verify the host can reach the test container's IP so that the host-to-container path (used by the forwarder and resolver) is proven.
4. The spike must verify the test container can reach the internet through NAT on ports 80, 443 and DNS so that egress for searx and blocky is proven.
5. The spike must verify that egress filtering blocks other outbound ports from the container so that filtering rules are proven to take effect.
6. The spike must verify that forwarded traffic destined for the container subnet from a non-`ve-*` interface is dropped so that LAN isolation is proven in mirrored mode.
7. The spike must verify NAT and forward rules match interfaces by pattern (`ve-*`) without hardcoding an uplink name, since mirrored mode mirrors Windows NIC names.
8. The spike must verify loopback port 8888 is free on both the Windows and WSL sides so that the forwarder can bind it.
9. The spike must verify a container can resolve and fetch over HTTPS while using the public fallback resolver so that searx's DNS plan is proven.
10. The spike must verify a service listening on a container's private IP can be reached from the host, and that other ports are closed by the container firewall, so that the one-port firewall model is proven.
11. The spike result must be recorded (pass, partial, or fail, with which checks failed) before continuing, so that later steps can be changed accordingly.
12. If any spike check fails, implementation must stop and this spec must be revised. The decision tree is in "Spike outcomes" below.
13. The throwaway test container and its rules must be removed after the spike, so that no spike artifacts remain.

### Step 1: searx container

14. Searx must run in a container with a private network, host IP 10.233.2.1 and container IP 10.233.2.2, so that it is network-isolated.
15. The container must start automatically at boot, be declarative and not ephemeral, so that it behaves like the native service did.
16. Searx must keep its existing settings (engines, server options), including the hardcoded secret key, unchanged, so that behavior doesn't change.
17. Searx must listen on the container IP port 8888 directly, with no reverse proxy, so that nothing sits between the forwarder and searx.
18. The searx container firewall must allow inbound TCP 8888 only so that no other port is reachable.
19. The searx container must use a public resolver (9.9.9.9) for DNS, independent of blocky, so that searx keeps working if blocky is down.
20. The searx container egress must be limited to ports 80 and 443 so that it can query search engines but nothing else.
21. A host-side forwarder must listen on 127.0.0.1 port 8888 only, and relay TCP to the container, so that searx is reachable from the host (and from Windows in mirrored mode) without exposing it on the LAN.
22. The forwarder must not bind 0.0.0.0 or any LAN interface so that nothing is reachable from the LAN.
23. The forwarder must start after the container at boot and recover if the container restarts, so that the URL keeps working.
24. The host must map `searx.home.arpa` to 127.0.0.1 via a static hosts entry so that the name works without depending on blocky or any DNS server.
25. Searx must be reachable at `http://searx.home.arpa:8888` from the host shell and from a browser, so that the user has the friendly name.
26. On WSL, adding `127.0.0.1 searx.home.arpa` to the Windows hosts file must let the Windows browser reach searx at the same URL, so that the user's browser workflow works. This is a manual one-time step.
27. The native `searxng` package must be removed from the host's system packages so that searx exists only in the container.
28. The native host `services.searx` must be removed so that nothing else binds port 8888 on the host.

### Step 2: blocky container

29. Blocky must run in a container with a private network, host IP 10.233.1.1 and container IP 10.233.1.2, so that it is isolated.
30. The container must start automatically at boot, be declarative and not ephemeral, so that DNS is available without manual steps.
31. Blocky must keep its existing settings (upstream DoH groups, bootstrap DNS, denylists, caching, log level), changed only in listen address, so that behavior stays the same.
32. Blocky must listen on the container IP port 53 (UDP and TCP) so that the host can reach it.
33. The blocky container firewall must allow inbound UDP and TCP 53 only so that no other port is reachable.
34. The blocky container egress must be limited to ports 53 and 443 so that it can reach upstream DoH resolvers and blocklist hosts but nothing else.
35. Host NAT must be enabled for the `ve-*` interfaces, matching by pattern and with no hardcoded uplink name, so that it works on WSL (mirrored) and on native NixOS.
36. Forward rules must drop traffic to 10.233.0.0/16 from any interface that is not `ve-*` so that the LAN cannot reach the containers.
37. No inbound port forwarding from the host or LAN to the containers must be configured, so the containers are reachable only from the host itself.
38. `dig @10.233.1.2 example.com` from the host must return an answer and a known blocked domain must return the configured block response, so that blocky is verified working before cutover.
39. Blocklists and DoH upstreams must download and resolve through the container's NAT egress so that blocking and resolution work.
40. The native host `services.blocky` must be removed so that only the container runs it.

### Step 3: resolver cutover

41. The host's nameservers must be set to blocky's container IP first, followed by a public fallback (9.9.9.9), so that DNS works even while blocky is starting at boot.
42. NetworkManager's nameserver insertion for 127.0.0.1 must be removed on hosts where NetworkManager is enabled so that it doesn't point at a dead resolver.
43. `services.resolved` must remain disabled so that it doesn't interfere with the resolver setup.
44. On WSL the resolv.conf generation must be disabled and the nameservers declared, so that the WSL-generated file doesn't override them.
45. WSL-specific and NetworkManager-specific settings must be guarded by conditions so that the same aspect applies to both hosts without errors.
46. After cutover, host DNS lookups must go through blocky (verified by a blocked domain returning the block response), so that ad blocking applies to host processes.
47. Stopping the blocky container must not break host DNS, because the fallback resolver takes over, so that the host stays online.
48. A host reboot must end with the host resolving names within a short time, using the fallback while blocky starts, and then using blocky, so that the boot gap is acceptable.

### Cross-cutting

49. Windows DNS must be unchanged. Blocky filters WSL-side DNS only, so that Windows is not affected.
50. Docker and excalidash behavior must be unchanged so that unrelated services keep working.
51. The aspect must evaluate and build on both hosts (`oric` and `yousuke`) so that it can eventually apply to both.
52. The change must not open any new listening port on 0.0.0.0 on the host so that LAN exposure does not increase.
53. Each step must be independently testable and leave the system working, so that rollout can stop after any step.

## Implementation Decisions

- **Scope:** all changes are in the existing `privacy` aspect. It's a single feature module, and no new aspect is needed. No other feature references searx or blocky.
- **Rollout order:** spike, then searx, then blocky, then resolver cutover. The cutover is last so DNS is confirmed working before the host depends on it.
- **Container model:** declarative NixOS containers (not oci or Docker), `privateNetwork = true`, `autoStart = true`, not ephemeral. No `forwardPorts`.
- **Addressing:** fixed IPs from the 10.233.0.0/16 range. Blocky is 10.233.1.1 (host) and 10.233.1.2 (container). Searx is 10.233.2.1 (host) and 10.233.2.2 (container). The spike uses 10.233.9.x. The range was chosen for low collision risk with Docker (172.17+) and typical LANs. Switch ranges only if the spike or an `ip route` check shows a collision (e.g. a corporate VPN using 10.233.x).
- **Searx port decision:** searx listens on 8888 on the container IP with no reverse proxy. An nginx proxy was considered and dropped, because it only added a second service and needed an internal port to avoid colliding with 8888. The port is 8888 and not 8080 because 8080 is used by the user's local development.
- **Forwarder:** a minimal TCP forwarder (socat-style systemd unit) on 127.0.0.1:8888 relaying to the container. It does no HTTP processing. Chosen over a reverse proxy to keep moving parts low.
- **Local name:** `searx.home.arpa` (RFC 8375 home-network suffix; `.local` avoided because of mDNS), mapped to 127.0.0.1 through the static hosts file, not blocky custom DNS, so it doesn't depend on blocky being up.
- **HTTP only:** no TLS or local CA for now.
- **Searx DNS:** the container uses 9.9.9.9 directly, independent of blocky.
- **Host resolver:** the host nameserver list is blocky's container IP first, then 9.9.9.9 as fallback.
- **Isolation:** NAT is enabled for `ve-*` interfaces. Egress is limited per container, and forwarded traffic into 10.233.0.0/16 from non-`ve-*` interfaces is dropped. Match by interface name pattern, not by a named uplink, since WSL mirrored mode mirrors Windows NICs. Inbound firewall per container is a single port.
- **Compatibility guards:** WSL-only settings (resolv.conf generation) are conditional on the WSL option being enabled. NetworkManager-only settings are conditional on NetworkManager being enabled. NixOS already marks `ve-*` unmanaged for NetworkManager.
- **Environment facts found:** the stateVersion is 26.05 (current container options). The `oric` host is WSL with `wsl-open` as the browser. The `yousuke` host uses NetworkManager. The firewall is the NixOS default with no custom rules. The `privacy` aspect is currently included through the `thom` user aspect, and that user differs from the WSL user `thomas`. Verify which host(s) actually receive the aspect before testing.
- **Windows side:** WSL runs in mirrored mode, so Windows and WSL share loopback, and the forwarder on 127.0.0.1:8888 is reachable from Windows. The Windows hosts file entry is manual because it can't be managed from Nix.

### Spike outcomes (how the spec changes)

- **All checks pass:** continue with Steps 1 to 3 as written.
- **Container boot fails on WSL** (systemd, cgroup or veth): private-network containers are not viable on `oric`. Revisit options with the user: (a) shared host network with filesystem-only isolation, (b) keep the native services on WSL and containerize on `yousuke` only (guard by host), or (c) abandon containers for systemd hardening of the native services. Do not proceed until the user picks.
- **Container boots but NAT or egress fails:** try an explicit external interface, alternative filtering (nftables versus iptables backend), or temporary plain NAT without egress filtering and document the reduced isolation. Confirm with the user before accepting reduced isolation.
- **Pattern-matched interface rules don't work** (mirrored NIC names): fall back to named interfaces discovered at runtime or a bridge setup. Re-confirm with the user.
- **LAN drop rule not effective or breaks traffic:** do not ship an unverified rule. Investigate the firewall backend, and ask the user before relying on default policy alone.
- **Port 8888 is taken on the Windows or WSL side:** choose another free loopback port with the user, and update the forwarder, the URL and the acceptance criteria that mention 8888.
- **Subnet collision found:** pick a different range with the user.
- **Any partial result:** record it and ask the user before continuing.

## Out of Scope

- Moving the searx `secret_key` to a secret file (planned later improvement).
- Pointing Windows DNS at blocky, or exposing blocky to Windows or LAN clients.
- DNS support for Docker containers or excalidash.
- TLS, a local CA, or any reverse proxy.
- Managing the Windows hosts file or the Windows firewall from Nix.
- Exposing either service to the LAN.
- Changes to excalidash, Docker, or other features.
- Documentation or README changes.
- Browser-level DNS-over-HTTPS settings.

## Further Notes

- The biggest unknown is nested nspawn, veth and NAT under WSL2 mirrored mode. This is why Step 0 exists and gates the rest of the spec.
- At boot, blocky starts a few seconds after the host. The fallback resolver covers the gap, so DNS can briefly bypass ad blocking.
- In mirrored mode, anything bound to 0.0.0.0 in WSL may be LAN-reachable depending on the Windows Hyper-V firewall. That is why the forwarder binds loopback only and the LAN drop rule exists.
- The Windows hosts entry is a one-time manual step: `127.0.0.1 searx.home.arpa`.
- Estimated effort: about 80–110 lines of Nix and one to three hours, mostly on the spike and on NAT and filter debugging.
- The aspect should eventually apply to both `oric` (WSL) and `yousuke`. Use the same config on both, with guards around host-specific bits.

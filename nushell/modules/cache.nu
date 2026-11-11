# This module is intended to be used by other modules
export module mod {

    # Returns the cache result if available or executes the given closure
    export def hit [
        key: string  # Cache key
        timeout: int  # Timeout in seconds after which the cache is invalidated
        closure: closure  # Will only be run if timeout is exceeded to refresh the cache value
    ] {
        try {
            stor create -t cache -c {
                key: str,
                expirystamp: int,
                value: str
            } o> (null-device);
        }

        let cache = (stor open).cache;

        let potential_result = (
            $cache
            | where key == $key and expirystamp > (date now | format date %s | into int)
        );

        if ($potential_result | is-not-empty) {
            return (
                $potential_result
                | first
                | get value
                | from json
            );
        }

        let value = do $closure;
        try {
            stor delete -t cache -w $"key == '($key)'" o> (null-device);
        };
        stor insert -t cache -d {
            key: $key,
            expirystamp: ($"in ($timeout) seconds" | date from-human | format date %s | into int),
            value: ($value | to json)
        };
        return $value;
    }

    # Clears the cache completely
    export def invalidate [] {
        try {
            stor delete -t cache o+e> (null-device);
        }
        return null;
    }
  
}

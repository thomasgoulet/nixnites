---
name: interview
description: Interview the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'interview me' trigger phrases.
---

Interview the user relentlessly until you reach a shared understanding.
Map this as a **design tree** - every decision branches into the decisions that hang off it.

Work the tree in **rounds**.
The **frontier** is every decision whose prerequisites are already settled - the questions you can ask _now_ without guessing at answers you haven't heard yet.
Ask the whole frontier in one round - number each question and give your recommended answer.
Word each question so "yes" accepts your recommended answer.
Then wait for the user's answers before the next round.
If the user does not answer one specific question assume the recommended answer.

If a *fact* can be found by exploring the environment (filesystem, tools, etc.), look it up and validate the with the users.
The *decisions*, though, are mine — put each one to me and wait for my answer.

The session is done when the frontier is empty - every branch of the design tree visited, nothing left silently assumed.
DO NOT ACT on it until the user confirms you have reached a shared understanding.

```round format
**Q1** - **<question title>** - <question body, might be multiple paragraphs, including multiple choices>

<your recommended answer>

---

**Q2** - **<question title>** - <question body, might be multiple paragraphs, including multiple choices>

<your recommended answer>
```


# Flutter Hot Update Technical Research

Status: active
Scope: Research structure, constraints, and candidate technical routes for a self-developed Flutter hot update solution.
Source of truth: this file
Last updated: 2026-04-07

## Context

This file is the active research note for the Flutter hot update solution space.
The current goal is not implementation yet.
The goal is to define the feasible technical boundary, compare candidate routes, and identify which route is worth prototyping first.

## Question

What kinds of "hot update" are technically and operationally feasible for Flutter, and which route is realistic for a self-developed production-oriented solution?

## Research Scope

- Clarify what can be updated dynamically in a Flutter app
- Separate feasible production paths from paths that are only possible in development or only possible with policy risk
- Compare implementation complexity, platform risk, runtime cost, and product flexibility
- Prepare a basis for a later prototype decision

## Non-Goals

- No implementation in this phase
- No premature commitment to a single architecture before feasibility is clearer
- No assumption that "full code push" is achievable just because some ecosystems support it

## Assumptions

- The repository is in research mode.
- The desired outcome is a self-developed solution, not a direct adoption of an existing commercial service.
- Discussion outputs from this file may later move into `docs/design/`, `docs/plan/`, or `docs/problem/`.

## Working Definitions

- "Hot update": deliver new behavior or content to an installed app without a full store-driven app release
- "Content update": update assets, config, templates, or business rules without shipping new compiled code
- "Code update": update executable logic after release
- "Self-developed solution": the project owns the update protocol, packaging, integrity checks, rollout, rollback, and runtime loading model

## Core Constraints To Research

- Flutter release apps normally run compiled Dart code rather than an always-interpreted runtime
- iOS policy risk is likely much tighter than Android for any model that resembles downloading executable code
- Flutter engine, Dart runtime mode, and AOT/JIT boundaries may strongly limit true code replacement
- Native plugin interfaces and platform channel contracts may make partial updates fragile
- A production solution needs integrity verification, version compatibility checks, rollback, and observability
- Even if something is technically possible, store policy and operational risk may still make it non-viable

## Candidate Routes

### Route A: Asset And Config Hot Update

Update only static resources and data:

- images
- localized text
- JSON config
- layout metadata
- experiment flags

Benefits:

- Lowest platform risk
- Simplest integrity and rollback model
- Most compatible with current mobile distribution rules

Limits:

- Cannot change arbitrary application logic
- Product flexibility depends on how much behavior is already data-driven

### Route B: Schema-Driven Or DSL-Driven UI/Logic

Ship a rendering engine inside the app and download declarative payloads:

- page schema
- component tree
- action graph
- business rules DSL

Benefits:

- Much more flexible than plain asset update
- Can create a "quasi-code-update" effect while keeping execution inside a controlled interpreter

Limits:

- Requires designing a stable schema/interpreter boundary
- Complex interactions, performance, debugging, and compatibility become harder
- Too much power in the DSL can recreate a scripting engine with policy risk

### Route C: Downloaded Script Or Bytecode Executed At Runtime

Try to load new logic dynamically through an interpreter, embedded runtime, or custom execution layer.

Benefits:

- Highest flexibility short of true binary replacement

Limits:

- Very high policy and security risk
- Likely the first route to be rejected by platform constraints
- Significantly raises sandboxing, compatibility, and auditing complexity

### Route D: Replace Or Load Compiled Flutter/Dart Artifacts

Attempt to update compiled code units, dynamic libraries, or runtime artifacts after release.

Benefits:

- Most similar to true code push in concept

Limits:

- Likely the most difficult route technically
- May conflict with Flutter runtime assumptions
- Likely unacceptable on at least part of the target platform set

### Route E: Hybrid Strategy

Combine multiple layers:

- stable native app shell
- local rendering/runtime engine
- remote schema/config/assets
- feature gating and rollback controls

Benefits:

- Most realistic path for balancing flexibility and policy safety
- Lets the system evolve gradually from simple update to richer remote-driven behavior

Limits:

- Requires careful boundary design
- Can become over-engineered if the capability model is not constrained early

## Evaluation Dimensions

- Technical feasibility in Flutter runtime
- iOS feasibility
- Android feasibility
- App store policy risk
- Security and tamper resistance
- Runtime performance
- Debuggability
- Backward compatibility
- Rollback simplicity
- Development cost
- Product flexibility

## Current Leaning

The most realistic research direction is probably not "full arbitrary Dart code hot update".
The more plausible direction is a hybrid model centered on controlled remote content, schema, or DSL execution inside a pre-shipped runtime boundary.
This is still a provisional conclusion and needs technical verification.

## Research Questions

- In a production Flutter app, what parts of runtime behavior can be updated without changing compiled Dart/native code?
- How hard is it to design a schema-driven or DSL-driven layer that is powerful enough to matter but constrained enough to remain maintainable?
- What exact platform-policy lines separate acceptable remote content from unacceptable remote code execution?
- Can Android and iOS share one architecture, or does a realistic solution require different capability levels per platform?
- What must be fixed in the preinstalled shell so remote updates remain compatible over time?
- What packaging, signing, manifest, diff, and rollback model would a self-developed update pipeline need?

## Near-Term Research Tasks

- Verify Flutter and Dart runtime boundaries relevant to post-release code updates
- Verify app-store policy constraints for remote logic delivery
- Study how far a schema-driven or DSL-driven approach can go before becoming a hidden scripting engine
- Define the minimum viable capability set for a first prototype
- Identify the smallest end-to-end prototype that proves or disproves the preferred route

## Discussion Notes

- The key first question is not "how to hot update Flutter code" but "what update boundary is both technically and operationally acceptable".
- If arbitrary post-release code execution is not viable, the real design problem becomes how expressive the remote-driven layer should be.
- A good solution likely depends more on boundary design than on raw transport or patching mechanics.
- "Full logic hot update" is the strongest option in product flexibility, because it can theoretically change almost any behavior after release.
- It is also the most difficult option technically, because Flutter mobile release builds are centered on compiled production artifacts rather than a development-style hot-reload runtime.
- It is not only a difficulty problem. For mainstream store distribution, arbitrary post-release code update also runs into policy constraints, especially on iOS.

## Evidence Snapshot

- Flutter documents that hot reload works only in debug mode, not release mode.
- Dart documents that production mobile/desktop apps use ahead-of-time compilation to native machine code.
- Apple App Store Review Guideline 2.5.2 says apps may not download, install, or execute code that introduces or changes app features or functionality.
- Google Play says apps distributed via Google Play may not self-update outside Google Play and may not download executable code such as dex, JAR, or `.so` files from elsewhere.
- Flutter deferred components do exist, but the official API says they can only deliver split-off parts of the same app already built and installed, cannot load new code written after distribution, and are Android-only.

## Open-Source References For Dynamicization

The ecosystem appears to split into two different layers:

- full dynamic runtime/frameworks
- low-level embedded execution engines

They should not be confused.
A project may use FFI internally without making FFI the main dynamicization model exposed to product teams.

### 1. WebF

Link:

- https://github.com/openwebf/webf

What it is:

- A Flutter-based web runtime that executes JavaScript with a QuickJS runtime
- Explicitly advertises compatibility with React, Vue, Svelte, Solid, and other web frameworks
- Uses a custom rendering engine on top of Flutter rather than a system WebView

Why it matters:

- This is the closest open-source example to a "React-like dynamic runtime on Flutter"
- It is not just config-driven UI; it is a real web-runtime approach embedded into Flutter

What is confirmed:

- React/Vue compatibility is explicitly documented
- QuickJS runtime is explicitly documented
- OTA deployment is explicitly positioned as a use case

What is not yet confirmed in this note:

- The README does not explicitly say "Dart FFI" in the lines reviewed
- There is clearly a substantial native layer, but the exact FFI vs platform-bridge split needs code-level inspection if this becomes a serious candidate

Initial assessment:

- Strong candidate for studying the "React-like runtime embedded in Flutter" direction
- More like "bring a web runtime into Flutter" than "native Flutter code hot update"

### 2. MXFlutter

Link:

- https://github.com/Tencent/mxflutter

What it is:

- Tencent's TypeScript/JavaScript framework for developing Flutter apps
- Uses JS bundle rendering and describes itself as referencing React Native in design
- Generates a WidgetTree in JavaScript and converts that description into real Flutter widgets

Why it matters:

- This is a classic large-company attempt at Flutter dynamicization through a JS runtime model
- It is structurally close to the idea you mentioned: front-end-like programming model, dynamic bundle delivery, Flutter-side rendering

What is confirmed:

- TypeScript/JavaScript development model is explicit
- JS bundle rendering is explicit
- Bidirectional JS/Dart calling is explicit
- The README directly says the design references React Native

What is not confirmed:

- I did not find explicit README evidence that MXFlutter's core runtime is specifically implemented via Dart FFI

Initial assessment:

- Important historical reference
- Strongly relevant conceptually
- Appears much older and less active than newer candidates, so likely better as a design reference than a direct adoption target

### 3. Fair

Link:

- https://github.com/wuba/Fair

What it is:

- A Flutter dynamic framework from 58.com
- Focuses on dynamically updating widget tree and state
- Uses Fair compiler plus JS distribution and dynamic bundles

Why it matters:

- One of the best-known open-source Flutter dynamicization projects in the Chinese ecosystem
- Good reference for bundle distribution, widget-tree dynamicization, and platform/tooling design

What is confirmed:

- Dynamic widget-tree and state update are explicit
- JS distribution is explicit
- The project positions itself as similar to React Native in delivery style

What is not confirmed:

- I did not find explicit README evidence that Fair's runtime relies on Dart FFI as a core mechanism

Initial assessment:

- Relevant as a Flutter-native dynamic framework reference
- Feels more like DSL/compiler/runtime conversion than a pure React-like embedded runtime

### 4. flutter_eval / dart_eval

Links:

- https://github.com/ethanblake4/flutter_eval
- https://pub.dev/packages/flutter_eval
- https://pub.dev/packages/dart_eval

What it is:

- A Dart bytecode compiler and interpreter
- Positions itself directly as code-push, dynamic widgets, and runtime evaluation for Flutter and Dart AOT apps

Why it matters:

- This is the clearest open-source example of trying to preserve a Dart-first dynamic execution story rather than switching fully to JS/web technologies
- It is useful if the goal is "stay in Dart semantics as much as possible"

What is confirmed:

- Runtime evaluation and code push are explicit
- It uses a custom bytecode interpreter written in Dart
- It supports loading update artifacts at runtime

What it is not:

- Not a Dart FFI-based dynamic engine in the material reviewed
- Not React-like in architecture

Initial assessment:

- Strong research target if we want a Dart-first dynamic route
- Less aligned with the "React-like + FFI" hypothesis

### 5. flutter_js

Link:

- https://github.com/abner/flutter_js

What it is:

- A low-level JavaScript engine wrapper for Flutter
- Uses QuickJS on Android through Dart FFI
- Uses JavaScriptCore on iOS through dart:ffi

Why it matters:

- This is the clearest direct evidence I found for the "FFI-backed script runtime inside Flutter" route
- It is not a complete dynamic UI framework by itself, but it is a strong building block for one

What is confirmed:

- Dart FFI is explicit
- QuickJS on Android is explicit
- JavaScriptCore on iOS is explicit
- The project explicitly discusses using JavaScriptCore on iOS to reduce App Store rejection risk

Initial assessment:

- Best match for the "FFI-powered embedded runtime" part of your hypothesis
- Not enough alone; it still needs a rendering model, API exposure boundary, and update protocol

### 6. flutter_dynamic

Link:

- https://github.com/Yingzi-Technology/flutter_dynamic

What it is:

- A custom interpreter-style engine that dynamically creates Flutter applications, including logic

Why it matters:

- Shows the "build a Dart-like interpreter and widget engine ourselves" route

What is confirmed:

- It supports dynamic UI and interpreted logic
- It explicitly acknowledges Flutter's native limitations for dynamic execution

What is not confirmed:

- I did not find explicit README evidence of Dart FFI usage

Initial assessment:

- Useful as a custom-interpreter reference
- Less obviously industrialized than WebF, Fair, or flutter_eval

### 7. flutter_qjs / quickjs

Links:

- https://pub.dev/packages/flutter_qjs
- https://pub.dev/packages/quickjs

What they are:

- Lower-level QuickJS bindings for Dart/Flutter
- Explicitly centered on `dart:ffi`

Why they matter:

- These are not full dynamic UI frameworks
- They are strong evidence that "embed a script runtime through FFI" is a real and practical technical route
- They are plausible building blocks if we ever decide to build our own controlled JS or DSL execution layer

What is confirmed:

- `flutter_qjs` explicitly says it is a Flutter JS engine using `quickjs` with `dart:ffi`
- `quickjs` explicitly says it is a Dart binding of QuickJS with FFI/native-assets based integration

Initial assessment:

- Very relevant if we care about the execution-engine layer
- Not enough alone for product dynamicization; still needs rendering, sandboxing, capability control, and rollout infrastructure

### 8. FuickJS article route: QuickJS + React + FFI + Flutter Widget mapping

Links:

- https://juejin.cn/post/7593234983755808778
- https://github.com/yanweimin7/fuckjs_demo

What it is:

- A dynamic Flutter rendering framework based on QuickJS
- Uses React syntax, Hooks, and lifecycle style for business logic and UI description
- Sends a JS-described UI tree to Flutter and maps it to native Flutter widgets
- Uses Dart FFI to interact directly with the C-layer QuickJS runtime

What is explicitly claimed in the article:

- Not WebView-based
- UI tree is passed through FFI and rendered as Flutter native widgets
- Direct FFI bridge is used to avoid JSON serialization overhead
- JS code can be delivered dynamically
- QuickJS bytecode can be loaded
- Framework code and business code can be split and loaded separately
- One Flutter page can load multiple pages from the same bundle and share one JS context

Why it matters:

- This is the closest concrete reference so far to the exact direction you mentioned
- It combines three layers into one stack:
  - JS runtime
  - React-like programming model
  - Flutter-native rendering target

Likely architecture shape:

- QuickJS executes business logic and component functions
- React-like reconciliation produces a virtual tree or patch set
- Flutter side receives a compact tree diff rather than raw full-tree snapshots
- Flutter maps the resulting structure into widget updates

Performance ideas mentioned or implied by this route:

- FFI bridge instead of heavier platform-channel or JSON bridge
- QuickJS bytecode loading to reduce startup cost
- Split framework/runtime code from business bundles
- Shared JS context across multiple pages
- Diff-based incremental patch instead of full-tree replacement
- Update coalescing or frame merging so multiple JS-side mutations are committed in fewer Flutter-side render passes

Why diff patch can help:

- Reduces transfer volume between JS runtime and Flutter runtime
- Avoids rebuilding the full widget description when only a small subtree changed
- Lowers object allocation and bridge overhead
- Makes large-list and high-frequency UI updates more realistic

Why merged-frame updates can help:

- Many state changes can be batched into one Flutter-side commit
- Reduces redundant layout/rebuild cycles
- Prevents repeated small updates from thrashing the render pipeline

Risks and open questions:

- The stronger the JS runtime becomes, the closer the system moves toward a general remote code execution model
- A React-like runtime still needs a carefully constrained native capability surface
- Widget identity, state retention, async side effects, and navigation consistency are hard problems
- Shared JS context is powerful, but it increases lifecycle and memory-management complexity
- The article claims are promising, but independent production-grade validation is still needed

Initial assessment:

- Technically credible as an engineering direction
- More realistic than true Dart AOT code replacement
- Strong candidate for the "high-flexibility but controlled runtime boundary" route
- Still high in complexity, but meaningfully more plausible than unrestricted Flutter code hot update

## Current Interpretation Of The Ecosystem

The exact phrase "React-like and implemented through Dart FFI" does not map cleanly to one dominant Flutter open-source project from the material reviewed.
What I found instead is a pattern:

- React-like or web-like dynamic frameworks:
  - WebF
  - MXFlutter
  - Fair to a lesser extent
- Dart-first interpreter route:
  - flutter_eval / dart_eval
- FFI-backed script engine building block:
  - flutter_js

So the most plausible reading of the claim is:

- the high-level programming model is React-like or JS-runtime-like
- the low-level execution engine may use Dart FFI to embed QuickJS or other native runtimes

That pattern is real.
But the complete product solution is usually a stack, not one single mechanism.

## Updated View On Full Logic Hot Update

### Why it looks attractive

- Maximum post-release flexibility
- Closest thing to "ship now, patch logic later"
- Minimizes store review dependence in theory

### Why it is hard

- Flutter mobile release mode is built for compiled production artifacts, not unrestricted runtime code replacement
- Compatibility boundaries across Dart code, Flutter engine behavior, native plugins, and platform channels become difficult to preserve
- Integrity, signing, rollback, and observability requirements become significantly harder

### Why it may be non-viable in practice

- iOS App Store policy appears fundamentally hostile to arbitrary downloaded executable logic
- Google Play also blocks direct executable-code download and self-update outside Play for mainstream app distribution
- Some interpreter-based or remote-driven models may be tolerated on Android under constraints, but that is materially different from true arbitrary logic hot update

### Practical conclusion

For Flutter mobile, "full logic hot update" should currently be treated as:

- strongest in capability
- highest in complexity
- highest in policy risk
- likely non-viable as a general App Store / Play Store production strategy if it means arbitrary new executable logic after release

This pushes the realistic solution space toward controlled remote-driven behavior rather than true unrestricted code push.

## Provisional Decision

Use this file as the primary research log for now.
Prioritize feasibility analysis of the update boundary before discussing transport details, backend protocol, or patch generation.

## Follow-up

- Add evidence-backed findings for runtime constraints and policy constraints
- Break out separate discussion files if specific subtopics become large enough
- Promote stable conclusions into design or problem docs later

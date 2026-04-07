# Archived Flutter Hot Update Technical Research

Status: archived
Scope: Historical discussion log for early Flutter hot update route exploration.
Replaces: /Users/zyyziyunying/flutter-hot-update-lab/docs/discussion/2026-04-07-flutter-hot-update-technical-discussion.md
Source of truth: /Users/zyyziyunying/flutter-hot-update-lab/docs/design/flutter-hot-update-react-like-direction.md
Last updated: 2026-04-08

## Context

This file preserves the first broad research pass over the Flutter hot update solution space.
It records the early route survey, constraints, and comparative discussion that later narrowed into the current React-like direction.

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

## Layered Model For The QuickJS + React + Flutter Route

To keep the discussion structured, this route can be split into five layers:

### Layer 1: Execution Layer

Responsibility:

- run JS or bytecode
- manage JS context lifecycle
- expose host APIs into the runtime

Typical choices:

- QuickJS runtime
- source bundle or precompiled bytecode
- one context per page, per bundle, or per app segment

Key questions:

- what exactly gets executed
- how code is loaded and verified
- how many contexts exist
- what native capabilities are visible to JS

### Layer 2: UI Description Layer

Responsibility:

- let business code describe UI and interaction declaratively
- preserve a component model, props, state, and lifecycle

Typical choices:

- React-like element tree
- Hooks-style state management
- custom components mapped to host Flutter widgets

Key questions:

- how expressive the component model should be
- how custom components compose
- how side effects are represented

### Layer 3: Patch Protocol Layer

Responsibility:

- turn tree changes into transportable update operations
- avoid replacing the whole UI tree on every change

Typical choices:

- node insert/remove/move/update ops
- prop diff
- event-binding diff
- navigation and imperative command ops

Key questions:

- what the patch format looks like
- how widget identity is preserved
- how stateful subtrees are addressed

### Layer 4: Flutter Render Mapping Layer

Responsibility:

- map the remote tree or patch operations into real Flutter widget updates
- preserve local state, layout stability, and interop with native Flutter pages

Typical choices:

- host component registry
- widget factory layer
- keyed node reconciliation on the Flutter side

Key questions:

- how much is stateless rebuild vs retained node state
- how navigation, gestures, scrolling, and async image loading are handled
- how mixed stacks with native Flutter pages are supported

### Layer 5: Scheduling Layer

Responsibility:

- decide when runtime changes are flushed into Flutter
- batch updates and coordinate commit timing

Typical choices:

- microtask batching
- frame-based flushing
- priority queues
- idle-time or threshold-based commit

Key questions:

- when to commit
- how to coalesce updates
- how to avoid render thrashing

## Current Discussion Order

- First: Layer 1 execution layer
- Then: Layer 2 UI description layer
- Then: Layer 3 patch protocol layer
- Then: Layer 4 Flutter render mapping layer
- Later: Layer 5 scheduling and performance strategy

## Layer Notes

### Layer 1 Notes: Execution Layer

Current interpretation:

- This route is not true Flutter/Dart release-code hot replacement
- It is an embedded-runtime model inside a preinstalled Flutter shell
- A JS engine such as QuickJS becomes the dynamic execution environment
- Flutter interacts with that runtime through a narrow host boundary, often via Dart FFI

Recommended boundary:

- load signed bundles or bytecode rather than arbitrary ad hoc scripts
- prefer bounded host APIs over exposing the entire app surface
- treat context lifecycle and capability exposure as architectural decisions, not implementation details

### Layer 2 Notes: UI Description Layer

Current interpretation:

- A React-like UI description layer is useful because it gives business code a declarative component model instead of forcing imperative Flutter-host commands
- The value is not "React" by brand name
- The value is a stable mental model: component tree, props, state, effects, and identity

Why this layer matters:

- Dynamic UI needs a representation that is more structured than raw script side effects
- Without a declarative tree, diffing, rollback, testing, and cross-version compatibility become much harder
- A component model gives the runtime a stable unit for update, reuse, and state retention

What this layer probably should contain:

- host component abstractions such as `Text`, `Column`, `Image`, `ListView`, `Button`
- user-defined composite components
- props
- local state
- controlled effect hooks or lifecycle hooks
- event callbacks represented as runtime-managed references rather than direct native closures

What this layer probably should not contain at first:

- arbitrary unrestricted host-object mutation
- full reflection over the Flutter widget system
- direct access to all native/plugin APIs from every component

Design principle:

- JS should describe intent and structure
- Flutter host should remain the renderer and capability owner

Current recommendation:

- If this route is pursued, the UI description layer should be deliberately smaller than full React DOM or full Flutter API surface
- It should start as a constrained component/runtime model designed for business pages, not an unconstrained universal UI language

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

## Risk Ranking Across The Five Layers

Current ranking by project-kill risk:

1. Layer 4: Flutter render mapping layer
2. Layer 2: UI description layer
3. Layer 1: execution layer
4. Layer 3: patch protocol layer
5. Layer 5: scheduling layer

### Why Layer 4 is the highest risk

- This is where all abstraction debt becomes real behavior bugs
- Widget identity, local state retention, navigation, gestures, scrolling, async resources, and mixed-stack interop all converge here
- A demo can make this layer look easy, but production stability usually breaks here first

### Why Layer 2 is the second highest risk

- If the component model is too weak, business teams cannot express enough
- If the model is too strong, the system becomes an uncontrolled scripting platform
- This layer defines how much power the dynamic side has and how maintainable that power remains

### Why Layer 1 is still strategically critical

- The runtime itself is technically feasible
- But capability exposure, bundle verification, context lifecycle, and policy boundary all depend on this layer
- It rarely kills the first demo, but it can kill production viability

### Why Layer 3 is important but more local

- A bad patch protocol hurts efficiency and correctness
- But it is usually repairable if the higher-level component and rendering model are sound

### Why Layer 5 is usually last

- Scheduling matters a lot for performance
- But if the first four layers are wrong, scheduling does not save the architecture
- It is more often an optimization and stabilization layer than the source of the core product risk

## Current Practical Recommendation

If this project ever prototypes the route, the first design energy should go into:

- constraining the host component model
- defining stable node/component identity
- defining what state is owned by JS versus Flutter
- designing mixed-stack navigation and lifecycle rules

The main danger is not "can QuickJS run".
The main danger is "can the system remain understandable and stable once real business pages, real state, and real navigation are placed on top of it".

## Strategic Positioning Of The QuickJS + React + FFI Route

Current recommendation:

- treat this route as a strong high-flexibility candidate
- do not assume it should automatically become the primary production strategy
- evaluate it against simpler dynamicization routes before committing

### Where this route is strong

- Much stronger than remote config or pure asset update
- More realistic than true Flutter/Dart release-code hot replacement
- Gives a real programmable dynamic layer rather than only parameterization
- Can support cross-platform business-page dynamicization with one runtime model

### Where this route is weak

- Architecture complexity is high
- Team cognitive load is high because the system spans JS runtime, Flutter host, bundle system, and rendering bridge
- Debugging and observability are harder than conventional Flutter
- Long-term maintainability risk is significant if the capability boundary is not kept small
- Policy review risk remains non-trivial because it still resembles downloaded logic, even if it is not direct Flutter code replacement

### Strategic role options

#### Option 1: Main strategy

Meaning:

- this becomes the default path for future dynamic business pages

When it makes sense:

- the product truly needs strong post-release flexibility
- the team accepts building and owning runtime infrastructure
- dynamic pages are expected to become an important long-term platform capability

Risk:

- highest commitment
- easiest way to overbuild too early

#### Option 2: Secondary capability

Meaning:

- normal Flutter remains primary
- this route is used only for high-change, high-experiment, or remotely driven surfaces

When it makes sense:

- the team wants meaningful dynamic ability without rewriting the entire app architecture
- only a subset of pages benefit from this power

Risk:

- mixed architecture overhead
- requires discipline about which pages qualify

#### Option 3: Research track / proving ground

Meaning:

- keep it as a technical exploration or prototype direction first
- use it to learn the real boundary before making product commitments

When it makes sense:

- the team is still uncertain about business need, policy tolerance, or maintenance cost
- there is not yet a clear target page type or rollout model

Risk:

- may never graduate if evaluation criteria stay vague

## Current Strategic Recommendation

At the current stage, the best position for this route is:

- not "final main strategy"
- not "discarded"
- but "priority research candidate with a likely future role as a secondary capability"

Why:

- It is much more credible than unrestricted Flutter code hot update
- It is much more powerful than simple config-driven dynamicization
- But it is still too heavy to declare as the default architecture before validating the business need and operational cost

## What This Route Must Prove To Earn Promotion

Before it can move from research candidate to production strategy, it should prove:

- a constrained host component model is enough for real business pages
- dynamic pages can coexist cleanly with normal Flutter pages
- bundle loading, verification, and rollback are manageable
- the debugging and release workflow are acceptable for the team
- platform and policy risk are acceptable for the intended distribution channel

## Interim Conclusion

This route currently looks best as:

- a serious technical direction
- a likely high-flexibility capability for selected surfaces
- not yet a justified default for the whole application architecture

## Horizontal Comparison Of Dynamicization Routes

To decide whether the QuickJS + React + FFI route deserves top priority, it should be compared against lighter alternatives.

### Route 1: Remote config / asset update

What it changes:

- text
- images
- layout parameters
- feature flags
- business thresholds

Strengths:

- lowest risk
- easiest rollout and rollback
- lowest policy pressure
- fastest time to value

Weaknesses:

- cannot express real page-level logic changes
- product flexibility is limited by what the native app pre-exposes

Strategic role:

- should almost always exist as a base capability
- not sufficient alone if the goal is strong dynamicization

### Route 2: Server-driven UI / schema-driven UI

What it changes:

- page structure
- component composition
- some interaction flow
- controlled business rules

Strengths:

- much safer than a general script runtime
- good fit for standard business pages
- easier to audit and constrain than arbitrary JS execution

Weaknesses:

- expressiveness is capped by the schema
- schema evolution can become difficult
- complex interactions become awkward if the schema grows too much

Strategic role:

- very strong mainstream candidate
- often the best first serious dynamicization route

### Route 3: DSL / rule engine

What it changes:

- business flow
- validation rules
- calculation logic
- controlled interaction behavior

Strengths:

- tighter control than general JS
- good for forms, pricing, workflows, decision logic
- can be highly portable and auditable

Weaknesses:

- hard to design well
- may become either too weak or accidentally turn into a poorly designed programming language
- UI expression is usually weaker than full component runtimes

Strategic role:

- useful when the dynamic target is mostly rules and workflows
- often pairs well with server-driven UI rather than replacing it

### Route 4: QuickJS + React + FFI + Flutter mapping

What it changes:

- business logic
- page structure
- component composition
- interaction behavior

Strengths:

- highest flexibility among realistic routes discussed so far
- closest to a true programmable dynamic platform
- can cover many cases that config/schema systems cannot

Weaknesses:

- highest system complexity among realistic routes
- highest maintenance and observability burden
- still carries policy and governance concerns

Strategic role:

- strong high-flexibility candidate
- likely better as a selective capability than a universal default

### Route 5: True post-release executable code replacement

What it changes:

- arbitrary executable logic

Strengths:

- theoretical maximum flexibility

Weaknesses:

- highest policy risk
- weakest production viability for mainstream Flutter mobile distribution

Strategic role:

- not a recommended primary route for this research direction

## Comparative Takeaway

If the goal is only "some dynamicization", then QuickJS + React + FFI is too heavy.
If the goal is "high-flexibility business page dynamicization", then it becomes much more attractive.

This suggests a layered strategic view:

- baseline capability:
  - remote config / asset update
- likely mainstream structured dynamicization:
  - server-driven UI and possibly DSL/rules
- high-flexibility advanced capability:
  - QuickJS + React + FFI route

## Current Ranking By Strategic Practicality

For a self-developed Flutter dynamicization roadmap, a practical ranking currently looks like:

1. Remote config / asset update as a mandatory foundation
2. Server-driven UI or schema-driven UI as the strongest mainstream candidate
3. QuickJS + React + FFI as the strongest high-flexibility candidate
4. DSL/rule engine as a specialized complement or domain-specific path
5. True executable code replacement as a non-primary research edge case

## Current Recommendation For Research Sequencing

The research should likely proceed in this order:

1. Define the baseline capability that every route would need anyway:
   - bundle/config delivery
   - integrity verification
   - rollback
   - compatibility versioning
2. Clarify whether the target business need is mostly:
   - content/layout flexibility
   - workflow/rule flexibility
   - near-programmable page flexibility
3. If the need is near-programmable page flexibility, keep the QuickJS + React + FFI route in the top candidate set.
4. Do not treat the most flexible route as automatically the best first production route.

## Business-Motivation Notes

The motivation for this research is stronger than ordinary mobile app iteration convenience.
The Flutter business is expected to run on hardware devices, so remote update value is materially higher.

Why this matters:

- asking users to download and install a new APK is possible, but operationally heavier
- device-side upgrade friction is higher than ordinary app content iteration
- faster remote correction of interaction or flow defects has higher practical value

## Current Target Capability Shape

The currently described hot-update demand is not primarily:

- simple text/image/config refresh

It is more likely centered on:

- interaction flow changes
- player-related UI behavior changes
- video resource loading logic changes

Interpretation:

- this pushes the target capability above plain remote config
- this may exceed what a narrow schema-only UI approach handles comfortably
- this makes a stronger dynamic route more attractive, but still does not automatically justify unrestricted code replacement

## Implication For Route Selection

If the main changing surface is player interaction flow plus resource-loading strategy, then the practical target is closer to:

- high-flexibility controlled dynamicization

rather than:

- low-flexibility content/config dynamicization

This increases the relevance of:

- server-driven flow plus rule capabilities
- or a runtime-backed route such as QuickJS + React + FFI for selected surfaces

It also suggests caution:

- if "resource loading logic" touches low-level media playback, native integration, decoder behavior, DRM, or hardware access, not all of that should be moved into the dynamic layer
- the dynamic layer is better suited to orchestration and business flow than to replacing the deepest media or device-specific runtime components

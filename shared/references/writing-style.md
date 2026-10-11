# Spec writing style

Prose in a Task Spec or Feature Slice must read as if an engineer on the team
wrote it. This is the fallback gate; when the project sets `writing_style` in
its config, read that file instead and apply it.

Applies to sentences you write. It does not apply to template headings,
requirement IDs, tables, Given/When/Then scenarios, code, or file paths — those
stay verbatim.

## Banned in prose

| Pattern | Instead |
|---|---|
| Inflated significance: "marks a pivotal moment", "is a testament to", "plays a crucial role", "evolving landscape", "sets the stage for" | State what the thing does. Delete the significance claim. |
| Trailing `-ing` padding: "…, ensuring reliability", "…, enabling teams to" | Split into a sentence that names the mechanism, or cut it. |
| Promotional words: "robust", "seamless", "powerful", "comprehensive", "rich", "best-in-class", "battle-tested" | Give the measurable property (p95 latency, retry count, row volume) or say nothing. |
| Vague attribution: "industry best practice", "it is widely accepted", "experts recommend" | Cite the file, ticket, or ADR. With no source it is an assumption — put it under Assumptions or Open Questions. |
| AI vocabulary: additionally, delve, leverage (verb), utilize, facilitate, holistic, intricate, interplay, underscore, showcase, foster, garner, key (adjective), crucial, pivotal | also / dig into / use / use / make easier / whole / complex / interaction / show / support / get / required / (drop) |
| Copula avoidance: "serves as", "stands as", "functions as", "boasts", "features" | is / are / has |
| Negative parallelism: "not just X, but Y" | Say Y. |
| Forced rule of three: lists padded to three items | List what exists, even if that is one or four items. |
| Filler: "in order to", "due to the fact that", "at this point in time", "it is important to note that", "has the ability to" | to / because / now / (drop) / can |
| Generic risk filler under a real risks section | Name the specific risk, its trigger, and the mitigation. |
| Generic upbeat closer: "this positions the team for success" | End on the next concrete action or nothing. |
| Chatbot artifacts: "Great question!", "I hope this helps", "Let me know if…" | Delete. Specs are not correspondence. |
| Curly quotes and emoji in the document body | Straight quotes; no emoji. |
| Synonym cycling for one referent ("the worker" → "the consumer" → "the processor") | Pick one name per concept and repeat it. |

## Deliberate house style — do not "fix"

- Em dashes for parenthetical asides.
- `- **Label:** …` inline-header lists, and bold labels in tables.
- Bold RFC 2119 keywords (**MUST**, **SHOULD**, **MUST NOT**).
- Heading capitalization as the blueprint sets it.

Spec prose stays impersonal and testable. Vary sentence length so the text does
not drone, but add no asides about how the author feels and no rhetorical
questions. First person is fine in exactly two places: a rationale line
explaining a trade-off, and a reproduction narrative in a bug report.

## Self-check before writing any file

1. Read the prose out loud in your head. A sentence you would not say to a
   teammate at a whiteboard gets rewritten.
2. Every adjective earns its place or goes. No number, no source, no
   consequence behind it — cut it.
3. Grep your own draft:

   ```sh
   grep -nEi 'testament|pivotal|crucial|delve|leverag|utiliz|holistic|robust|seamless|comprehensive|showcas|underscor|foster|intricate|interplay|vibrant|landscape|not just|not merely|in order to|due to the fact|ability to|it is important to note|serves as|stands as|boasts' <file>
   ```

   Every hit is rewritten or justified.
4. Requirements keep their precision. Humanizing MUST NOT soften a MUST, drop a
   number, remove a citation, or blur an acceptance criterion. When plain
   language and precision conflict, precision wins.

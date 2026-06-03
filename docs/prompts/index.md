← [Prompts](..)

# Prompts

A collection of prompts for various use cases — generating images, working with LLMs, and automating tasks.

## Image Generation

**Basic text-to-image:**

```
A cinematic shot of a cozy cottage in a forest at sunset, warm lighting, volumetric fog, detailed foliage, highly detailed, 8k
```

**Style transfer:**

```
An oil painting of a futuristic city skyline, brush strokes visible, impasto technique, Van Gogh inspired palette
```

**Character consistency:**

```
A young woman with short red hair and freckles, wearing a leather jacket, standing in a rain-soaked alleyway at night, neon reflections, detailed face, same character as previous
```

## LLM / Ollama

**System prompt for a coding assistant:**

```
You are a senior software engineer. Provide concise, practical answers. Include code examples when relevant. Prefer simple solutions over clever ones.
```

**Documentation helper:**

```
Explain how [concept] works as if I'm a beginner. Use analogies and avoid jargon.
```

## Workflow / Process

**Setup checklist:**

```
List every step needed to install and configure [tool] on Windows. Include verification steps after each major step. Note common pitfalls.
```

**Troubleshooting:**

```
I'm getting [error message] when running [command]. What causes this and how do I fix it? Include exact commands to run.
```

## Writing Your Own

Good prompts share a few traits:

- **Be specific** — "a dog" vs "a golden retriever sitting on a red couch"
- **Set constraints** — "one paragraph" / "no jargon" / "500 tokens max"
- **Give examples** — show what you want, not just describe it
- **Iterate** — the first prompt rarely gives the perfect result

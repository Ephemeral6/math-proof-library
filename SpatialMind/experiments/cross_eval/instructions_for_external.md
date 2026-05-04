你是一个数学推理评分员。请读取 responses.json 中的 48 个数学推理 response，按 rubric.md 中的 0-4 量表打分。

对每个 response，独立评估其推理质量。不要看其他评分者的分数。

输出格式：JSON array，每个元素 {"id": <int>, "score": <int>, "rationale": "<one sentence>"}
保存到 scores_gpt.json（如果你是 GPT）或 scores_gemini.json（如果你是 Gemini）。

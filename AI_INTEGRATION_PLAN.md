# MealMap AI Integration Plan

This document captures a future-ready AI integration plan for MealMap so we can implement it later without re-thinking the product and technical direction from scratch.

Pricing and model notes in this document are based on official OpenAI documentation checked on April 3, 2026 and should be re-verified before production rollout.

Official references:

- https://platform.openai.com/docs/guides/latest-model
- https://platform.openai.com/docs/pricing/
- https://platform.openai.com/docs/api-reference/responses/compact?api-mode=responses
- https://platform.openai.com/docs/guides/structured-outputs?api-mode=responses
- https://help.openai.com/en/articles/4936856-what-are-tokens-and-how-to-count-them

## 1. Product Goal

Use AI to make meal planning smarter without replacing the deterministic logic that already works well locally.

AI should improve:

- which meals are recommended first
- how a weekly plan is assembled
- why a recipe is a good fit
- what substitutions make sense for missing ingredients

AI should **not** own:

- pantry persistence
- shopping list math
- serving multipliers
- leftover quantity accounting
- budget totals

Those should stay local, testable, and deterministic.

## 2. Recommended Starting Model

### Phase 1 default

- `gpt-5-mini`

Why:

- lower cost
- good enough for ranking, explanation, and weekly plan suggestions
- safer starting point for an MVP AI layer

### Phase 2 escalation model

- `gpt-5.2`

Use it only when needed for:

- harder weekly planning prompts
- more nuanced substitution logic
- advanced planning constraints

## 3. Architecture Direction

Do not call OpenAI directly from the iOS app.

Recommended flow:

1. iOS app sends planning context to MealMap backend.
2. Backend prepares a compact AI payload.
3. Backend calls OpenAI Responses API.
4. OpenAI returns structured JSON.
5. Backend validates and normalizes response.
6. iOS app displays AI results.
7. Existing local logic still computes shopping list, costs, leftovers, and final inventory effects.

### Why a backend is required

- API keys must stay private
- rate limiting should be controlled server-side
- request/response logging is easier
- prompt updates can happen without shipping a new app
- we can add caching later

## 4. Suggested AI Use Cases

### A. AI Recommendation Re-ranking

Current local engine creates a deterministic shortlist.

Future AI layer:

- receive top 10-15 candidate recipes
- re-rank them
- produce short explanations

Example output:

- recipe ID
- rank
- confidence
- reason
- budget fit
- waste reduction note

This is the safest first AI feature.

### B. AI Weekly Planner

User intent examples:

- cheap meals this week
- use expiring items first
- vegetarian week
- high-protein but low-cost plan

AI returns:

- recipe IDs for each day/meal slot
- suggested servings
- leftover reuse opportunities
- short reasoning

The app then runs local validation and local shopping list generation.

### C. AI Ingredient Substitutions

AI can extend the existing rule-based substitution layer with:

- culturally relevant alternatives
- pantry-aware substitutions
- lower-cost alternatives
- dietary alternatives

### D. Natural Language Planning

Examples:

- "Make this week cheaper"
- "Plan dinners under 30 minutes"
- "Use spinach and yogurt before they expire"

This should come after structured planning is stable.

## 5. How Token Pricing Works

OpenAI text usage is typically priced by tokens, not by a flat fee per request.

Two main categories:

- input tokens: what we send
- output tokens: what the model returns

Helpful rule of thumb:

- 1 token is roughly 4 English characters
- non-English languages can use more tokens

That means Turkish prompts may cost a bit more than short English ones.

## 6. Example Pricing Reference

As checked on April 3, 2026:

### `gpt-5-mini`

- input: `$0.25 / 1M tokens`
- output: `$2.00 / 1M tokens`

### `gpt-5.2`

- input: `$1.75 / 1M tokens`
- output: `$14.00 / 1M tokens`

Verify before launch because pricing can change.

## 7. Practical Cost Scenarios

These are rough planning estimates, not invoices.

### Scenario 1: lightweight recommendation call

- 2,000 input tokens
- 400 output tokens

Estimated cost:

- `gpt-5-mini`: about `$0.0013`
- `gpt-5.2`: about `$0.0091`

### Scenario 2: weekly planner call

- 5,000 input tokens
- 800 output tokens

Estimated cost:

- `gpt-5-mini`: about `$0.00285`
- `gpt-5.2`: about `$0.01995`

### Scenario 3: monthly estimate at 10,000 lightweight calls

- `gpt-5-mini`: about `$13`
- `gpt-5.2`: about `$91`

## 8. Cost Control Strategy

To keep AI practical:

- use local logic first
- only send shortlisted recipes
- keep prompts compact
- ask for structured JSON, not long prose
- cap output size
- cache repeated recommendation contexts
- use AI only when the user actually triggers it

Recommended production rule:

- default to local engine
- use AI as an enhancement layer
- fall back to local recommendations if AI fails or times out

## 9. Structured Output Shape

Use structured JSON instead of free-form text.

Example shape:

```json
{
  "recommendations": [
    {
      "recipe_id": "UUID",
      "rank": 1,
      "reason": "Uses 3 expiring ingredients and fits the budget.",
      "budget_fit": "good",
      "leftover_opportunity": true,
      "swap_suggestions": ["Use labneh instead of yogurt if needed."]
    }
  ]
}
```

Benefits:

- easier to validate
- easier to render in SwiftUI
- safer than parsing natural language
- more testable

## 10. Suggested Backend Payload

Do not send full raw database dumps.

Send only compact planning context:

- pantry items
  - name
  - quantity
  - unit
  - category
  - expiration window
- candidate recipes
  - id
  - title
  - tags
  - prep time
  - estimated cost
  - ingredient list
- weekly planning preferences
  - budget cap
  - meal style filters
  - preferred meal types
  - current week plan summary

Avoid sending unnecessary user metadata.

## 11. Rollout Plan

### Phase 1

- add backend placeholder
- add AI service protocol in app
- add `AIRecommendationEngine`
- keep existing local engine as fallback
- ship AI recommendation re-ranking only

### Phase 2

- add AI weekly planning endpoint
- let AI suggest meal slots and servings
- keep local shopping list generation

### Phase 3

- add AI substitution support
- add natural language planner

### Phase 4

- add user personalization
- learn favorite patterns
- add opt-in history-based planning improvements

## 12. MealMap Codebase Fit

The current app is already close to ready for this direction.

Best integration points later:

- `RecommendationEngine.swift`
- `DashboardViewModel.swift`
- `RecipesViewModel.swift`
- `WeeklyPlannerView.swift`
- `SettingsView.swift`

Suggested future folders:

- `MealMap/Services/API/`
- `MealMap/Services/AI/`
- `MealMap/Models/AI/`

## 13. Settings and UX Plan

Future settings ideas:

- enable AI suggestions
- AI-powered weekly planning
- share pantry and recipe context with AI
- fallback to local mode when offline

Future UI entry points:

- dashboard card: `AI Pick For Tonight`
- planner button: `Generate AI Week`
- recipe detail: `AI Alternatives`

## 14. Risks

- cost creep if prompts are too large
- low trust if explanations are vague
- user frustration if AI suggestions ignore pantry reality
- privacy concerns if users do not understand what is sent

Mitigation:

- show explanation for every AI suggestion
- keep deterministic rules for final calculations
- add server-side logging and request limits
- keep AI opt-in during early rollout

## 15. Recommended First Implementation

If we start AI in MealMap, the best first version is:

1. `gpt-5-mini`
2. server-side OpenAI integration
3. shortlist re-ranking only
4. structured JSON output
5. local fallback enabled at all times

This gives the best balance of:

- low risk
- low cost
- visible user value
- minimal disruption to current architecture

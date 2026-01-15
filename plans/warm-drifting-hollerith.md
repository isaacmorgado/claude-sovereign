# Plan: Segment Leaderboard by User Gender

## Status: ✅ IMPLEMENTED

The leaderboard is now segmented by gender and properly connected to the user's gender selection.

## Gender Flow (Verified Working)
```
/gender page → GenderContext → /analysis page → sessionStorage → /results page → ResultsContext → LeaderboardTab
```

1. User selects gender on `/gender` page → stored in `GenderContext`
2. Analysis page reads `useGender()` and passes to `sessionStorage`
3. Results page reads from `sessionStorage` → initializes `ResultsContext`
4. `LeaderboardTab` reads `useResults().gender` → sets `genderFilter`
5. Leaderboard API filters by that gender

## Changes Made

### `src/components/results/tabs/LeaderboardTab.tsx`
- ✅ Removed gender filter dropdown
- ✅ Added `useEffect` to auto-set `genderFilter` from `useResults().gender`
- ✅ Updated headers: "Males Leaderboard" / "Females Leaderboard"
- ✅ Shows gender-specific rank and count

## Connection Points
| Step | File | How Gender is Passed |
|------|------|---------------------|
| 1 | `/gender/page.tsx` | User selects, stored in `GenderContext` |
| 2 | `/analysis/page.tsx` | `useGender()` → `sessionStorage` |
| 3 | `/results/page.tsx` | `sessionStorage` → `ResultsProvider` |
| 4 | `ResultsContext.tsx` | `initialData.gender` → context state |
| 5 | `LeaderboardTab.tsx` | `useResults().gender` → `setGenderFilter()` |

## No Additional Changes Needed
The gender selected on the `/gender` page is already correctly flowing through to the leaderboard.

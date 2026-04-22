# VIP Combinations Auto-Generation Feature

## Overview

The VIP Combinations section now automatically generates combination predictions whenever you add or update predictions in other VIP categories. This ensures that users always have fresh, curated multi-match predictions.

## How It Works

### Automatic Generation

When you create or update a prediction in any VIP category (except VIP Combination itself), the system automatically:

1. **Collects Today's VIP Predictions**: Gathers all pending predictions from VIP categories scheduled for today
2. **Selects Best Picks**: Chooses up to 5 diverse predictions based on:
   - Odds value (higher is prioritized)
   - Time diversity (spreads picks across different match times)
3. **Generates Combination**: Creates a multi-match combination prediction with:
   - Combined odds calculation
   - Formatted prediction text listing all matches
   - Automatic tracking of pending/won/lost status

### Triggered By

The combination generator runs automatically when you:
- ✅ Create a new prediction in any VIP category
- ✅ Update an existing prediction in any VIP category
- ✅ Update match results for VIP predictions

### Manual Generation

You can also manually regenerate combinations at any time using the **"Generate Combo"** floating action button on the Admin Dashboard. This is useful when:
- You want to refresh combinations with the latest picks
- You've added multiple predictions and want to see the best combination
- You want to create a new combination for tomorrow's matches

## Technical Details

### Selection Algorithm

The combination generator uses a smart selection algorithm:

```
1. Query all VIP categories (excluding vipCombination)
2. Filter for today's pending predictions
3. Sort by odds (descending - highest odds first)
4. Select up to 5 picks with time diversity
5. Calculate combined odds (multiply individual odds)
6. Create formatted combination text
7. Save to vipCombination category
```

### Combined Odds Calculation

The combined odds are calculated by multiplying the individual odds:
```
Combined Odds = Odds₁ × Odds₂ × Odds₃ × ... × Oddsₙ
```

Example:
- Match 1: 2.00 odds
- Match 2: 1.80 odds
- Match 3: 2.20 odds
- **Combined: 2.00 × 1.80 × 2.20 = 7.92 odds**

### Data Structure

Each VIP combination prediction contains:
- **League**: "VIP Combo"
- **Home Team**: "Multi-Match"
- **Away Team**: "Combination"
- **Match Time**: Time of the first match in the combination
- **Prediction**: Multi-line text with all matches:
  ```
  1. TeamA vs TeamB - Prediction1
  2. TeamC vs TeamD - Prediction2
  3. TeamE vs TeamF - Prediction3
  ...
  ```
- **Odds**: Combined odds (formatted to 2 decimal places)
- **Result**: pending/won/lost
- **Score**: "--" initially

## Usage Examples

### Example 1: Adding a VIP Prediction

```dart
// Admin adds a new prediction to "Correct Score VIP"
await controller.createMatch(
  category: correctScoreVipCategory,
  draft: PredictionDraft(
    league: "Premier League",
    matchTime: DateTime.now(),
    homeTeam: "Arsenal",
    awayTeam: "Chelsea",
    prediction: "2-1",
    odds: "8.50",
  ),
);

// 🎉 VIP Combination is automatically updated with this pick!
```

### Example 2: Manual Generation

```dart
// Press the "Generate Combo" button on dashboard
// System collects all today's VIP predictions
// Creates fresh combination with best 5 picks
```

## Firestore Structure

Combinations are stored in the same structure as other predictions:

```
predictions/
  └── vipCombination/
      └── matches/
          └── [auto-generated-id]/
              ├── league: "VIP Combo"
              ├── homeTeam: "Multi-Match"
              ├── awayTeam: "Combination"
              ├── time: [Timestamp]
              ├── prediction: "1. Arsenal vs Chelsea - 2-1\n2. ..."
              ├── odds: "45.50"
              ├── result: "pending"
              └── score: "--"
```

## Future Enhancements

Potential improvements for the combination system:

1. **Smart Result Tracking**: Automatically mark combinations as won/lost based on individual match results
2. **Custom Selection**: Allow admins to manually select which predictions to include
3. **Multiple Combinations**: Generate different combination types (safe, risky, balanced)
4. **Historical Performance**: Track which combination strategies perform best
5. **Time-Based Combos**: Generate separate morning/afternoon/evening combinations

## Configuration

The combination generator is configured in:
- **Service**: `packages/predictions_shared/lib/src/services/combination_generator.dart`
- **Controller**: `apps/admin_app/lib/features/controllers/prediction_admin_controller.dart`
- **UI**: `apps/admin_app/lib/features/dashboard/dashboard_screen.dart`

### Adjustable Parameters

You can modify these in `combination_generator.dart`:

```dart
// Maximum picks in a combination (default: 5)
final selectedPicks = _selectBestPicks(allPicks, maxPicks: 5);

// Match query limit per category (default: 5)
.limit(5)

// Time range (default: today only)
final todayStart = DateTime(now.year, now.month, now.day);
final todayEnd = todayStart.add(const Duration(days: 1));
```

## Troubleshooting

### Combination Not Generated

If combinations aren't being generated:

1. ✅ Check that you're adding to a **VIP category** (not free)
2. ✅ Ensure predictions have a **match time for today**
3. ✅ Verify predictions have **odds values**
4. ✅ Check Firebase connection

### Empty Combinations

If combinations are empty:
- No pending VIP predictions scheduled for today
- Try manually generating after adding more predictions

### Duplicate Combinations

The system creates a new combination each time. To avoid duplicates:
- Delete old combinations manually from the VIP Combination category
- Or implement auto-cleanup (future enhancement)

## Best Practices

1. **Add VIP predictions early in the day** for better combinations
2. **Review generated combinations** before they go live
3. **Manually regenerate** after adding multiple predictions at once
4. **Keep odds realistic** for accurate combined odds calculation
5. **Delete old combinations** to keep the list clean

---

*Last updated: November 28, 2025*

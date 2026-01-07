# Analytics Event Specification

## Game: Batch-20260107-110734-puzzle-01
## Version: 1.0

## Overview

This document defines all analytics events tracked in the game.
Events are sent to Firebase Analytics and forwarded to the GameFactory backend.

## Global Parameters

All events include these parameters:

| Parameter | Type | Description |
|-----------|------|-------------|
| `user_id` | string | Anonymous user identifier |
| `session_id` | string | Current session identifier |
| `app_version` | string | App version string |
| `platform` | string | android/ios |
| `device_model` | string | Device model name |

## Required Events

### `game_start`

Fired when player starts a game session

**Parameters:**
- `session_id`
- `timestamp`

### `level_start`

Fired when player begins a level

**Parameters:**
- `level`
- `attempt_number`

### `level_complete`

Fired when player completes a level

**Parameters:**
- `level`
- `score`
- `time_seconds`
- `stars_earned`

### `level_fail`

Fired when player fails a level

**Parameters:**
- `level`
- `score`
- `fail_reason`
- `time_seconds`

### `unlock_prompt_shown`

Fired when ad unlock prompt is displayed

**Parameters:**
- `level`
- `prompt_type`

### `rewarded_ad_started`

Fired when player initiates rewarded ad

**Parameters:**
- `level`
- `ad_placement`

### `rewarded_ad_completed`

Fired when rewarded ad finishes successfully

**Parameters:**
- `level`
- `reward_type`
- `reward_value`

### `rewarded_ad_failed`

Fired when rewarded ad fails or is cancelled

**Parameters:**
- `level`
- `failure_reason`

### `level_unlocked`

Fired when a new level is unlocked

**Parameters:**
- `level`
- `unlock_method`

## Custom Events

### `move_made`

**Parameters:**
- `move_type`
- `position`

### `hint_used`

**Parameters:**
- `hint_type`
- `level`

### `combo_achieved`

**Parameters:**
- `combo_size`
- `points`

## Funnels

### onboarding

Track user journey from install to first completion

**Steps:**
1. `game_start`
2. `level_start:1`
3. `level_complete:1`
4. `level_complete:3`

### monetization

Track ad monetization funnel

**Steps:**
1. `level_complete:3`
2. `unlock_prompt_shown`
3. `rewarded_ad_started`
4. `rewarded_ad_completed`
5. `level_unlocked`

### retention

Track progression through game

**Steps:**
1. `level_complete:1`
2. `level_complete:5`
3. `level_complete:10`

### engagement

Track daily engagement depth

**Steps:**
1. `game_start`
2. `level_start`
3. `level_complete`


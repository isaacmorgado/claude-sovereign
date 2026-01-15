# Username & Terms and Conditions Implementation Plan

## Overview
Add username/alias requirement during signup and mandatory Terms & Conditions acceptance before account creation.

## Key Requirements
- **Username Required**: Users must create a unique username/alias (not their real name)
- **T&C Checkbox**: Users must check a checkbox confirming they've read and accept the Terms & Conditions
- **Cannot Proceed Without Both**: Account creation blocked until both requirements are met
- **Username Display**: The username will be displayed on the leaderboard instead of auto-generated anonymous names

---

## Database Changes

### Modify: `users` table
```sql
ALTER TABLE users ADD COLUMN username VARCHAR(30) UNIQUE NOT NULL;
ALTER TABLE users ADD COLUMN terms_accepted_at TIMESTAMP;
CREATE INDEX idx_users_username ON users(username);
```

### Update: `leaderboard_scores` table
The `anonymous_name` column will now store the user's chosen username instead of auto-generated names.

---

## Backend Changes (FastAPI)

### 1. Update User Model
**File:** `looksmaxx-api/app/models/user.py`

```python
class User(Base):
    __tablename__ = "users"

    # Existing fields...

    # NEW FIELDS
    username = Column(String(30), unique=True, nullable=False, index=True)
    terms_accepted_at = Column(DateTime, nullable=True)
```

### 2. Update Registration Schema
**File:** `looksmaxx-api/app/schemas/auth.py`

```python
class UserCreate(BaseModel):
    email: EmailStr
    password: str
    username: str  # NEW
    terms_accepted: bool  # NEW

    @validator('username')
    def validate_username(cls, v):
        if len(v) < 3:
            raise ValueError('Username must be at least 3 characters')
        if len(v) > 30:
            raise ValueError('Username must be 30 characters or less')
        if not v.isalnum() and '_' not in v:
            raise ValueError('Username can only contain letters, numbers, and underscores')
        if v.lower().startswith('user_'):
            raise ValueError('Username cannot start with "User_"')
        return v

    @validator('terms_accepted')
    def validate_terms(cls, v):
        if not v:
            raise ValueError('You must accept the Terms & Conditions')
        return v
```

### 3. Update Register Endpoint
**File:** `looksmaxx-api/app/routers/auth.py`

```python
@router.post("/register", response_model=TokenResponse)
async def register(user_data: UserCreate, db: Session = Depends(get_db)):
    # Check if email already exists
    existing_email = db.query(User).filter(User.email == user_data.email).first()
    if existing_email:
        raise HTTPException(status_code=400, detail="Email already registered")

    # Check if username already exists (case-insensitive)
    existing_username = db.query(User).filter(
        func.lower(User.username) == user_data.username.lower()
    ).first()
    if existing_username:
        raise HTTPException(status_code=400, detail="Username already taken")

    # Create user with username and terms acceptance
    user = User(
        email=user_data.email,
        password_hash=hash_password(user_data.password),
        username=user_data.username,
        terms_accepted_at=datetime.utcnow() if user_data.terms_accepted else None
    )

    db.add(user)
    db.commit()
    db.refresh(user)

    # Generate token...
    return TokenResponse(access_token=token, user=user_schema)
```

### 4. Add Username Availability Check Endpoint
**File:** `looksmaxx-api/app/routers/auth.py`

```python
@router.get("/check-username/{username}")
async def check_username(username: str, db: Session = Depends(get_db)):
    """Check if a username is available (no auth required)"""

    # Validate format
    if len(username) < 3:
        return {"available": False, "reason": "Too short"}
    if len(username) > 30:
        return {"available": False, "reason": "Too long"}
    if not all(c.isalnum() or c == '_' for c in username):
        return {"available": False, "reason": "Invalid characters"}
    if username.lower().startswith('user_'):
        return {"available": False, "reason": "Reserved prefix"}

    # Check database
    exists = db.query(User).filter(
        func.lower(User.username) == username.lower()
    ).first()

    return {
        "available": not exists,
        "reason": "Username taken" if exists else None
    }
```

### 5. Update Leaderboard Score Submission
**File:** `looksmaxx-api/app/routers/leaderboard.py`

When submitting a score, use the user's username instead of generating an anonymous name:

```python
@router.post("/score", response_model=UserRankResponse)
async def submit_score(
    data: ScoreSubmission,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Check if user already has a leaderboard entry
    existing = db.query(LeaderboardScore).filter(
        LeaderboardScore.user_id == current_user.id
    ).first()

    if existing:
        # Update existing entry
        existing.score = data.score
        existing.gender = data.gender
        existing.anonymous_name = current_user.username  # Use username
        # ... other updates
    else:
        # Create new entry
        entry = LeaderboardScore(
            user_id=current_user.id,
            score=data.score,
            gender=data.gender,
            anonymous_name=current_user.username,  # Use username
            # ... other fields
        )
        db.add(entry)

    db.commit()
    # ... return rank
```

---

## Frontend Changes (Next.js)

### 1. Create Terms & Conditions Page
**File:** `looksmaxx-app/src/app/terms/page.tsx`

```typescript
export default function TermsPage() {
  return (
    <div className="min-h-screen bg-neutral-950 py-12 px-4">
      <div className="max-w-3xl mx-auto">
        <h1 className="text-3xl font-bold text-white mb-8">Terms & Conditions</h1>

        <div className="prose prose-invert">
          <h2>1. Acceptance of Terms</h2>
          <p>By creating an account on Looksmaxx, you agree to these Terms & Conditions...</p>

          <h2>2. Age Requirement</h2>
          <p>You must be at least 18 years old to use this service...</p>

          <h2>3. Privacy & Data Usage</h2>
          <p>Your facial analysis data and photos may be stored and processed...</p>

          <h2>4. Leaderboard Participation</h2>
          <p>By creating an account, you consent to having your analysis score
          displayed on the public leaderboard under your chosen username.
          Your face photo may be visible to other users...</p>

          <h2>5. Educational Purpose</h2>
          <p>This app is for educational and entertainment purposes only.
          Results should not be taken as medical or professional advice...</p>

          <h2>6. No Harassment</h2>
          <p>Users agree not to use information from the leaderboard to
          harass, bully, or demean other users...</p>

          <h2>7. Account Termination</h2>
          <p>We reserve the right to terminate accounts that violate these terms...</p>
        </div>
      </div>
    </div>
  );
}
```

### 2. Update API Client
**File:** `looksmaxx-app/src/lib/api.ts`

```typescript
// Add username availability check
async checkUsername(username: string): Promise<{ available: boolean; reason: string | null }> {
  const res = await fetch(`${this.baseUrl}/auth/check-username/${encodeURIComponent(username)}`);
  return res.json();
}

// Update register method
async register(data: {
  email: string;
  password: string;
  username: string;
  termsAccepted: boolean;
}): Promise<AuthResponse> {
  const res = await fetch(`${this.baseUrl}/auth/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      email: data.email,
      password: data.password,
      username: data.username,
      terms_accepted: data.termsAccepted,
    }),
  });

  if (!res.ok) {
    const error = await res.json();
    throw new Error(error.detail || 'Registration failed');
  }

  return res.json();
}
```

### 3. Create/Update Signup Page
**File:** `looksmaxx-app/src/app/signup/page.tsx` (or existing auth component)

```typescript
'use client';

import { useState, useEffect, useCallback } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { api } from '@/lib/api';
import { Check, X, Loader2 } from 'lucide-react';
import { debounce } from 'lodash';

export default function SignupPage() {
  const router = useRouter();
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    confirmPassword: '',
    username: '',
    termsAccepted: false,
  });
  const [usernameStatus, setUsernameStatus] = useState<{
    checking: boolean;
    available: boolean | null;
    reason: string | null;
  }>({ checking: false, available: null, reason: null });
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  // Debounced username check
  const checkUsernameAvailability = useCallback(
    debounce(async (username: string) => {
      if (username.length < 3) {
        setUsernameStatus({ checking: false, available: false, reason: 'Too short' });
        return;
      }

      setUsernameStatus({ checking: true, available: null, reason: null });

      try {
        const result = await api.checkUsername(username);
        setUsernameStatus({
          checking: false,
          available: result.available,
          reason: result.reason,
        });
      } catch {
        setUsernameStatus({ checking: false, available: null, reason: 'Check failed' });
      }
    }, 500),
    []
  );

  useEffect(() => {
    if (formData.username) {
      checkUsernameAvailability(formData.username);
    }
  }, [formData.username, checkUsernameAvailability]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    // Validation
    if (!formData.username || usernameStatus.available !== true) {
      setError('Please choose a valid, available username');
      return;
    }

    if (formData.password !== formData.confirmPassword) {
      setError('Passwords do not match');
      return;
    }

    if (!formData.termsAccepted) {
      setError('You must accept the Terms & Conditions');
      return;
    }

    setIsLoading(true);

    try {
      await api.register({
        email: formData.email,
        password: formData.password,
        username: formData.username,
        termsAccepted: formData.termsAccepted,
      });
      router.push('/dashboard');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Registration failed');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-neutral-950 flex items-center justify-center p-4">
      <div className="w-full max-w-md">
        <h1 className="text-2xl font-bold text-white text-center mb-8">Create Account</h1>

        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Email */}
          <div>
            <label className="block text-sm text-neutral-400 mb-2">Email</label>
            <input
              type="email"
              value={formData.email}
              onChange={(e) => setFormData({ ...formData, email: e.target.value })}
              className="w-full bg-neutral-900 border border-neutral-800 rounded-lg px-4 py-3 text-white focus:border-cyan-500 focus:outline-none"
              required
            />
          </div>

          {/* Username */}
          <div>
            <label className="block text-sm text-neutral-400 mb-2">
              Username <span className="text-neutral-600">(displayed on leaderboard)</span>
            </label>
            <div className="relative">
              <input
                type="text"
                value={formData.username}
                onChange={(e) => setFormData({ ...formData, username: e.target.value })}
                placeholder="Choose a unique username"
                className={`w-full bg-neutral-900 border rounded-lg px-4 py-3 pr-10 text-white focus:outline-none ${
                  usernameStatus.available === true
                    ? 'border-green-500'
                    : usernameStatus.available === false
                    ? 'border-red-500'
                    : 'border-neutral-800 focus:border-cyan-500'
                }`}
                required
              />
              <div className="absolute right-3 top-1/2 -translate-y-1/2">
                {usernameStatus.checking ? (
                  <Loader2 size={18} className="text-neutral-500 animate-spin" />
                ) : usernameStatus.available === true ? (
                  <Check size={18} className="text-green-500" />
                ) : usernameStatus.available === false ? (
                  <X size={18} className="text-red-500" />
                ) : null}
              </div>
            </div>
            {usernameStatus.reason && (
              <p className={`text-xs mt-1 ${usernameStatus.available ? 'text-green-400' : 'text-red-400'}`}>
                {usernameStatus.reason}
              </p>
            )}
            <p className="text-xs text-neutral-600 mt-1">
              3-30 characters, letters, numbers, and underscores only
            </p>
          </div>

          {/* Password */}
          <div>
            <label className="block text-sm text-neutral-400 mb-2">Password</label>
            <input
              type="password"
              value={formData.password}
              onChange={(e) => setFormData({ ...formData, password: e.target.value })}
              className="w-full bg-neutral-900 border border-neutral-800 rounded-lg px-4 py-3 text-white focus:border-cyan-500 focus:outline-none"
              required
              minLength={8}
            />
          </div>

          {/* Confirm Password */}
          <div>
            <label className="block text-sm text-neutral-400 mb-2">Confirm Password</label>
            <input
              type="password"
              value={formData.confirmPassword}
              onChange={(e) => setFormData({ ...formData, confirmPassword: e.target.value })}
              className="w-full bg-neutral-900 border border-neutral-800 rounded-lg px-4 py-3 text-white focus:border-cyan-500 focus:outline-none"
              required
            />
          </div>

          {/* Terms & Conditions Checkbox */}
          <div className="flex items-start gap-3">
            <input
              type="checkbox"
              id="terms"
              checked={formData.termsAccepted}
              onChange={(e) => setFormData({ ...formData, termsAccepted: e.target.checked })}
              className="mt-1 w-4 h-4 rounded border-neutral-700 bg-neutral-900 text-cyan-500 focus:ring-cyan-500 focus:ring-offset-neutral-950"
            />
            <label htmlFor="terms" className="text-sm text-neutral-400">
              I have read and agree to the{' '}
              <Link href="/terms" target="_blank" className="text-cyan-400 hover:underline">
                Terms & Conditions
              </Link>
              . I understand that my score and username will be displayed on the public leaderboard.
            </label>
          </div>

          {/* Error Message */}
          {error && (
            <div className="p-3 bg-red-500/10 border border-red-500/30 rounded-lg text-red-400 text-sm">
              {error}
            </div>
          )}

          {/* Submit Button */}
          <button
            type="submit"
            disabled={isLoading || !formData.termsAccepted || usernameStatus.available !== true}
            className="w-full py-3 bg-cyan-500 hover:bg-cyan-600 disabled:bg-neutral-700 disabled:cursor-not-allowed text-white font-semibold rounded-lg transition-colors"
          >
            {isLoading ? 'Creating Account...' : 'Create Account'}
          </button>

          {/* Login Link */}
          <p className="text-center text-neutral-500 text-sm">
            Already have an account?{' '}
            <Link href="/login" className="text-cyan-400 hover:underline">
              Log in
            </Link>
          </p>
        </form>
      </div>
    </div>
  );
}
```

---

## Implementation Order

1. **Database Migration**
   - Add `username` and `terms_accepted_at` columns to users table
   - Create index on username

2. **Backend - User Model**
   - Update User model with new fields

3. **Backend - Auth Schemas**
   - Update UserCreate schema with username and terms_accepted validators

4. **Backend - Auth Router**
   - Update register endpoint
   - Add check-username endpoint

5. **Backend - Leaderboard**
   - Update score submission to use username instead of anonymous_name

6. **Frontend - API Client**
   - Add checkUsername method
   - Update register method

7. **Frontend - Terms Page**
   - Create /terms page with Terms & Conditions content

8. **Frontend - Signup Page**
   - Add username field with real-time availability checking
   - Add T&C checkbox with link
   - Disable submit until both requirements met

9. **Testing**
   - Test username validation (length, characters, uniqueness)
   - Test T&C checkbox requirement
   - Test leaderboard displays username correctly

---

## Validation Rules

### Username
| Rule | Requirement |
|------|-------------|
| Length | 3-30 characters |
| Characters | Letters, numbers, underscores only |
| Case | Case-insensitive uniqueness check |
| Reserved | Cannot start with "User_" (reserved for legacy) |
| Real-time | Check availability as user types (debounced 500ms) |

### Terms & Conditions
| Rule | Requirement |
|------|-------------|
| Checkbox | Must be checked to submit form |
| Link | Opens /terms in new tab |
| Timestamp | Store `terms_accepted_at` when user registers |

---

## Files Summary

### Backend (MODIFY)
| File | Changes |
|------|---------|
| `app/models/user.py` | Add username, terms_accepted_at columns |
| `app/schemas/auth.py` | Add username, terms_accepted validators |
| `app/routers/auth.py` | Update register, add check-username endpoint |
| `app/routers/leaderboard.py` | Use username for anonymous_name |

### Frontend (CREATE)
| File | Purpose |
|------|---------|
| `src/app/terms/page.tsx` | Terms & Conditions page |

### Frontend (MODIFY)
| File | Changes |
|------|---------|
| `src/lib/api.ts` | Add checkUsername, update register |
| `src/app/signup/page.tsx` | Add username field, T&C checkbox |

---

## Migration Script

```sql
-- Add columns
ALTER TABLE users ADD COLUMN username VARCHAR(30);
ALTER TABLE users ADD COLUMN terms_accepted_at TIMESTAMP;

-- Migrate existing users (generate usernames from existing anonymous names or IDs)
UPDATE users SET username = 'User_' || SUBSTRING(id::text, 1, 6) WHERE username IS NULL;

-- Make username required and unique
ALTER TABLE users ALTER COLUMN username SET NOT NULL;
ALTER TABLE users ADD CONSTRAINT users_username_unique UNIQUE (username);

-- Create index
CREATE INDEX idx_users_username ON users(username);

-- Update leaderboard to use usernames
UPDATE leaderboard_scores ls
SET anonymous_name = u.username
FROM users u
WHERE ls.user_id = u.id;
```

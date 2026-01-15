"use client";

import { useState, useEffect, useCallback, Suspense } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import Link from "next/link";
import { Eye, EyeOff } from "lucide-react";
import { api } from "@/lib/api";

function CheckIcon({ className }: { className?: string }) {
  return (
    <svg className={className} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <polyline points="20 6 9 17 4 12" />
    </svg>
  );
}

function XIcon({ className }: { className?: string }) {
  return (
    <svg className={className} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <line x1="18" y1="6" x2="6" y2="18" />
      <line x1="6" y1="6" x2="18" y2="18" />
    </svg>
  );
}

function LoaderIcon({ className }: { className?: string }) {
  return (
    <svg className={`${className} animate-spin`} viewBox="0 0 24 24" fill="none">
      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
      <path
        className="opacity-75"
        fill="currentColor"
        d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
      />
    </svg>
  );
}

function SignupForm() {
  const router = useRouter();
  const searchParams = useSearchParams();

  const [formData, setFormData] = useState({
    email: "",
    password: "",
    confirmPassword: "",
    username: "",
    referralCode: "",
    termsAccepted: false,
  });
  const [usernameStatus, setUsernameStatus] = useState<{
    checking: boolean;
    available: boolean | null;
    reason: string | null;
  }>({ checking: false, available: null, reason: null });
  const [referralStatus, setReferralStatus] = useState<{
    checking: boolean;
    valid: boolean | null;
    message: string | null;
  }>({ checking: false, valid: null, message: null });
  const [error, setError] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);

  // Pre-fill referral code from URL if present
  useEffect(() => {
    const ref = searchParams.get("ref") || searchParams.get("referral");
    if (ref) {
      setFormData(prev => ({ ...prev, referralCode: ref.toUpperCase() }));
    }
  }, [searchParams]);

  // Debounced username check
  const checkUsernameAvailability = useCallback(async (username: string) => {
    if (username.length < 3) {
      setUsernameStatus({ checking: false, available: false, reason: "Too short" });
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
      setUsernameStatus({ checking: false, available: null, reason: "Check failed" });
    }
  }, []);

  // Debounced referral code validation
  const validateReferralCode = useCallback(async (code: string) => {
    if (!code) {
      setReferralStatus({ checking: false, valid: null, message: null });
      return;
    }

    setReferralStatus({ checking: true, valid: null, message: null });

    try {
      const result = await api.validateReferralCode(code);
      setReferralStatus({
        checking: false,
        valid: result.valid,
        message: result.message,
      });
    } catch {
      setReferralStatus({ checking: false, valid: null, message: "Validation failed" });
    }
  }, []);

  useEffect(() => {
    if (formData.username.length >= 3) {
      const timer = setTimeout(() => {
        checkUsernameAvailability(formData.username);
      }, 500);
      return () => clearTimeout(timer);
    } else if (formData.username.length > 0) {
      setUsernameStatus({ checking: false, available: false, reason: "Too short" });
    } else {
      setUsernameStatus({ checking: false, available: null, reason: null });
    }
  }, [formData.username, checkUsernameAvailability]);

  useEffect(() => {
    if (formData.referralCode.length >= 3) {
      const timer = setTimeout(() => {
        validateReferralCode(formData.referralCode);
      }, 500);
      return () => clearTimeout(timer);
    } else {
      setReferralStatus({ checking: false, valid: null, message: null });
    }
  }, [formData.referralCode, validateReferralCode]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    // Validation
    if (!formData.username || usernameStatus.available !== true) {
      setError("Please choose a valid, available username");
      return;
    }

    if (formData.password.length < 8) {
      setError("Password must be at least 8 characters");
      return;
    }

    if (formData.password !== formData.confirmPassword) {
      setError("Passwords do not match");
      return;
    }

    if (!formData.termsAccepted) {
      setError("You must accept the Terms & Conditions");
      return;
    }

    // If referral code is provided but invalid, warn but allow signup
    if (formData.referralCode && referralStatus.valid === false) {
      setError("The referral code is invalid. You can continue without it or enter a valid code.");
      return;
    }

    setIsLoading(true);

    try {
      const response = await api.register({
        email: formData.email,
        password: formData.password,
        username: formData.username,
        termsAccepted: formData.termsAccepted,
        referralCode: formData.referralCode || undefined,
      });

      // Store token
      localStorage.setItem("auth_token", response.access_token);
      api.setToken(response.access_token);

      // Store referral discount if valid code was used (extract from message)
      if (formData.referralCode && referralStatus.valid && referralStatus.message) {
        // Extract discount percentage from message like "Code applied! 40% discount from Nick J"
        const match = referralStatus.message.match(/(\d+)%/);
        if (match) {
          localStorage.setItem("referral_discount", match[1]);
        }
      }

      router.push("/gender");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Registration failed");
    } finally {
      setIsLoading(false);
    }
  };

  const isFormValid =
    formData.email &&
    formData.password.length >= 8 &&
    formData.password === formData.confirmPassword &&
    usernameStatus.available === true &&
    formData.termsAccepted;

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-black px-4 py-8">
      <div className="w-full max-w-sm">
        {/* Logo and Header */}
        <div className="mb-8">
          <div className="flex justify-center mb-6">
            <div className="h-8 w-8 rounded bg-cyan-400/20 flex items-center justify-center">
              <span className="text-cyan-400 text-sm font-bold">L</span>
            </div>
          </div>
          <h1 className="text-2xl font-semibold tracking-tight text-center text-white mb-2">
            Create Account
          </h1>
          <p className="text-sm text-neutral-400 text-center">
            Join LOOKSMAXX and start your analysis
          </p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          {/* Email */}
          <div>
            <label className="block text-sm text-neutral-400 mb-1.5">Email</label>
            <input
              type="email"
              value={formData.email}
              onChange={(e) => setFormData({ ...formData, email: e.target.value })}
              className="w-full h-11 px-3.5 text-sm bg-black border border-neutral-700 rounded-lg text-white focus:outline-none focus:border-cyan-400 transition-all"
              placeholder="you@example.com"
              required
            />
          </div>

          {/* Username */}
          <div>
            <label className="block text-sm text-neutral-400 mb-1.5">
              Username <span className="text-neutral-600">(shown on leaderboard)</span>
            </label>
            <div className="relative">
              <input
                type="text"
                value={formData.username}
                onChange={(e) => setFormData({ ...formData, username: e.target.value })}
                placeholder="Choose a unique username"
                className={`w-full h-11 px-3.5 pr-10 text-sm bg-black border rounded-lg text-white focus:outline-none transition-all ${
                  usernameStatus.available === true
                    ? "border-green-500"
                    : usernameStatus.available === false
                    ? "border-red-500"
                    : "border-neutral-700 focus:border-cyan-400"
                }`}
                required
              />
              <div className="absolute right-3 top-1/2 -translate-y-1/2">
                {usernameStatus.checking ? (
                  <LoaderIcon className="w-4 h-4 text-neutral-500" />
                ) : usernameStatus.available === true ? (
                  <CheckIcon className="w-4 h-4 text-green-500" />
                ) : usernameStatus.available === false ? (
                  <XIcon className="w-4 h-4 text-red-500" />
                ) : null}
              </div>
            </div>
            {usernameStatus.reason && (
              <p
                className={`text-xs mt-1 ${
                  usernameStatus.available ? "text-green-400" : "text-red-400"
                }`}
              >
                {usernameStatus.reason}
              </p>
            )}
            <p className="text-xs text-neutral-600 mt-1">
              3-30 characters, letters, numbers, and underscores only
            </p>
          </div>

          {/* Password */}
          <div>
            <label className="block text-sm text-neutral-400 mb-1.5">Password</label>
            <div className="relative">
              <input
                type={showPassword ? "text" : "password"}
                value={formData.password}
                onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                className="w-full h-11 px-3.5 pr-10 text-sm bg-black border border-neutral-700 rounded-lg text-white focus:outline-none focus:border-cyan-400 transition-all"
                placeholder="Minimum 8 characters"
                required
                minLength={8}
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-neutral-500 hover:text-neutral-300 transition-colors"
              >
                {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
              </button>
            </div>
            {formData.password && formData.password.length < 8 && (
              <p className="text-xs text-red-400 mt-1">Password must be at least 8 characters</p>
            )}
            {formData.password && formData.password.length >= 8 && (
              <p className="text-xs text-green-400 mt-1">Password strength: Good</p>
            )}
          </div>

          {/* Confirm Password */}
          <div>
            <label className="block text-sm text-neutral-400 mb-1.5">Confirm Password</label>
            <div className="relative">
              <input
                type={showConfirmPassword ? "text" : "password"}
                value={formData.confirmPassword}
                onChange={(e) => setFormData({ ...formData, confirmPassword: e.target.value })}
                className={`w-full h-11 px-3.5 pr-10 text-sm bg-black border rounded-lg text-white focus:outline-none transition-all ${
                  formData.confirmPassword && formData.password !== formData.confirmPassword
                    ? "border-red-500"
                    : formData.confirmPassword && formData.password === formData.confirmPassword
                    ? "border-green-500"
                    : "border-neutral-700 focus:border-cyan-400"
                }`}
                placeholder="Re-enter your password"
                required
              />
              <button
                type="button"
                onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-neutral-500 hover:text-neutral-300 transition-colors"
              >
                {showConfirmPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
              </button>
            </div>
            {formData.confirmPassword && formData.password !== formData.confirmPassword && (
              <p className="text-xs text-red-400 mt-1">Passwords do not match</p>
            )}
            {formData.confirmPassword && formData.password === formData.confirmPassword && (
              <p className="text-xs text-green-400 mt-1">Passwords match</p>
            )}
          </div>

          {/* Referral Code */}
          <div>
            <label className="block text-sm text-neutral-400 mb-1.5">
              Referral Code <span className="text-neutral-600">(optional)</span>
            </label>
            <div className="relative">
              <input
                type="text"
                value={formData.referralCode}
                onChange={(e) => setFormData({ ...formData, referralCode: e.target.value.toUpperCase() })}
                placeholder="INFLUENCER-CODE"
                className={`w-full h-11 px-3.5 pr-10 text-sm bg-black border rounded-lg text-white focus:outline-none transition-all ${
                  referralStatus.valid === true
                    ? "border-green-500"
                    : referralStatus.valid === false
                    ? "border-red-500"
                    : "border-neutral-700 focus:border-cyan-400"
                }`}
              />
              <div className="absolute right-3 top-1/2 -translate-y-1/2">
                {referralStatus.checking ? (
                  <LoaderIcon className="w-4 h-4 text-neutral-500" />
                ) : referralStatus.valid === true ? (
                  <CheckIcon className="w-4 h-4 text-green-500" />
                ) : referralStatus.valid === false ? (
                  <XIcon className="w-4 h-4 text-red-500" />
                ) : null}
              </div>
            </div>
            {referralStatus.message && (
              <p
                className={`text-xs mt-1 ${
                  referralStatus.valid ? "text-green-400" : "text-red-400"
                }`}
              >
                {referralStatus.message}
              </p>
            )}
          </div>

          {/* Terms & Conditions Checkbox */}
          <div className="flex items-start gap-3 pt-2">
            <input
              type="checkbox"
              id="terms"
              checked={formData.termsAccepted}
              onChange={(e) => setFormData({ ...formData, termsAccepted: e.target.checked })}
              className="mt-0.5 w-4 h-4 rounded border-neutral-600 bg-black text-cyan-400 focus:ring-cyan-400 focus:ring-offset-black cursor-pointer"
            />
            <label htmlFor="terms" className="text-sm text-neutral-400 cursor-pointer">
              I have read and agree to the{" "}
              <Link
                href="/terms"
                target="_blank"
                className="text-cyan-400 hover:underline"
              >
                Terms & Conditions
              </Link>
              . I understand that my score and username will be displayed on the public
              leaderboard.
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
            disabled={isLoading || !isFormValid}
            className="w-full h-11 bg-cyan-400 hover:shadow-[0_0_20px_rgba(34,211,238,0.3)] disabled:bg-neutral-800 disabled:text-neutral-500 disabled:cursor-not-allowed disabled:shadow-none text-black font-medium rounded-lg transition-all flex items-center justify-center gap-2"
          >
            {isLoading ? (
              <>
                <LoaderIcon className="w-4 h-4" />
                Creating Account...
              </>
            ) : (
              "Create Account"
            )}
          </button>

          {/* Login Link */}
          <p className="text-center text-neutral-500 text-sm pt-2">
            Already have an account?{" "}
            <Link href="/login" className="text-cyan-400 hover:underline">
              Log in
            </Link>
          </p>
        </form>
      </div>
    </div>
  );
}

export default function SignupPage() {
  return (
    <Suspense fallback={
      <div className="min-h-screen flex items-center justify-center bg-black">
        <LoaderIcon className="w-8 h-8 text-cyan-400" />
      </div>
    }>
      <SignupForm />
    </Suspense>
  );
}

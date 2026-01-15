"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";

// Google Icon Component matching FaceIQ exactly
function GoogleIcon({ className }: { className?: string }) {
  return (
    <svg className={className} viewBox="0 0 24 24">
      <path
        d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
        fill="#4285F4"
      />
      <path
        d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
        fill="#34A853"
      />
      <path
        d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
        fill="#FBBC05"
      />
      <path
        d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
        fill="#EA4335"
      />
    </svg>
  );
}

export default function LoginPage() {
  const router = useRouter();
  const [referralCode, setReferralCode] = useState("");
  const [isApplying, setIsApplying] = useState(false);

  const handleApplyCode = () => {
    if (!referralCode.trim()) return;
    setIsApplying(true);
    setTimeout(() => {
      setIsApplying(false);
    }, 1000);
  };

  const handleGoogleSignIn = () => {
    // TODO: Implement Google OAuth
    router.push("/gender");
  };

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-black px-4">
      <div className="w-full max-w-sm">
        {/* Logo and Header */}
        <div className="mb-10">
          <div className="flex justify-center mb-6">
            {/* Logo - 32x32 like FaceIQ */}
            <div className="h-8 w-8 rounded bg-[#00f3ff]/20 flex items-center justify-center">
              <span className="text-[#00f3ff] text-sm font-bold">L</span>
            </div>
          </div>
          <h1 className="text-2xl font-semibold tracking-tight text-center text-white mb-2">
            Sign in to LOOKSMAXX
          </h1>
          <p className="text-sm text-neutral-400 text-center">
            Continue with your Google account
          </p>
        </div>

        {/* Sign In Options */}
        <div className="space-y-4">
          {/* Google Sign In Button - FaceIQ style */}
          <button
            onClick={handleGoogleSignIn}
            className="w-full h-11 inline-flex items-center justify-center gap-3 rounded-lg border border-neutral-700 bg-black px-4 text-sm font-medium text-white shadow-sm transition-all hover:bg-white/5 hover:border-neutral-500 focus:outline-none focus:ring-2 focus:ring-[#00f3ff] focus:ring-offset-2 focus:ring-offset-black"
          >
            <GoogleIcon className="w-5 h-5" />
            Continue with Google
          </button>

          {/* Terms and Privacy */}
          <p className="text-xs text-center text-neutral-500">
            By signing in, you agree to our{" "}
            <Link
              href="/terms"
              target="_blank"
              className="text-neutral-300 hover:text-white underline underline-offset-2"
            >
              Terms of Service
            </Link>{" "}
            and{" "}
            <Link
              href="/privacy"
              target="_blank"
              className="text-neutral-300 hover:text-white underline underline-offset-2"
            >
              Privacy Policy
            </Link>
          </p>

          {/* Divider with text */}
          <div className="relative">
            <div className="absolute inset-0 flex items-center">
              <div className="w-full border-t border-neutral-800"></div>
            </div>
            <div className="relative flex justify-center text-xs">
              <span className="bg-black px-2 text-neutral-500">
                Have a referral code?
              </span>
            </div>
          </div>

          {/* Referral Code Input */}
          <div className="space-y-3">
            <div className="flex gap-2">
              <input
                type="text"
                placeholder="REFERRAL-CODE"
                value={referralCode}
                onChange={(e) => setReferralCode(e.target.value.toUpperCase())}
                className="flex-1 h-11 px-3.5 text-sm bg-black border border-neutral-700 rounded-lg placeholder:text-neutral-600 text-white focus:outline-none focus:border-neutral-500 disabled:bg-neutral-900 disabled:text-neutral-500 disabled:cursor-not-allowed transition-all"
              />
              <button
                onClick={handleApplyCode}
                disabled={!referralCode.trim() || isApplying}
                className="h-11 px-5 bg-[#00f3ff] text-black rounded-lg text-sm font-medium transition-all hover:shadow-[0_0_20px_rgba(0,243,255,0.3)] focus:outline-none disabled:bg-neutral-800 disabled:text-neutral-500 disabled:cursor-not-allowed disabled:shadow-none"
              >
                {isApplying ? "..." : "Apply"}
              </button>
            </div>
          </div>

          {/* Create Account Link */}
          <p className="text-center text-neutral-500 text-sm pt-2">
            Don&apos;t have an account?{" "}
            <Link href="/signup" className="text-[#00f3ff] hover:underline">
              Sign up
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}

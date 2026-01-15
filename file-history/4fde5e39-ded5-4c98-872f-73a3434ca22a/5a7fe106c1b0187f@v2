"use client";

import { useState } from "react";
import Link from "next/link";
import { api } from "@/lib/api";

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

function CheckIcon({ className }: { className?: string }) {
  return (
    <svg className={className} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <polyline points="20 6 9 17 4 12" />
    </svg>
  );
}

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState("");
  const [error, setError] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    if (!email) {
      setError("Please enter your email");
      return;
    }

    setIsLoading(true);

    try {
      await api.requestPasswordReset(email);
      setIsSuccess(true);
    } catch {
      // Don't reveal if email exists or not for security
      setIsSuccess(true);
    } finally {
      setIsLoading(false);
    }
  };

  if (isSuccess) {
    return (
      <div className="min-h-screen flex flex-col items-center justify-center bg-black px-4">
        <div className="w-full max-w-sm text-center">
          <div className="flex justify-center mb-6">
            <div className="h-12 w-12 rounded-full bg-green-500/20 flex items-center justify-center">
              <CheckIcon className="w-6 h-6 text-green-500" />
            </div>
          </div>
          <h1 className="text-2xl font-semibold text-white mb-2">Check your email</h1>
          <p className="text-neutral-400 mb-6">
            If an account exists for {email}, we&apos;ve sent a password reset link.
            Please check your inbox and spam folder.
          </p>
          <Link
            href="/login"
            className="inline-block w-full h-11 bg-[#00f3ff] hover:shadow-[0_0_20px_rgba(0,243,255,0.3)] text-black font-medium rounded-lg transition-all leading-[44px]"
          >
            Back to Login
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-black px-4">
      <div className="w-full max-w-sm">
        {/* Logo and Header */}
        <div className="mb-10">
          <div className="flex justify-center mb-6">
            <div className="h-8 w-8 rounded bg-[#00f3ff]/20 flex items-center justify-center">
              <span className="text-[#00f3ff] text-sm font-bold">L</span>
            </div>
          </div>
          <h1 className="text-2xl font-semibold tracking-tight text-center text-white mb-2">
            Reset your password
          </h1>
          <p className="text-sm text-neutral-400 text-center">
            Enter your email and we&apos;ll send you a reset link
          </p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          {/* Email */}
          <div>
            <label className="block text-sm text-neutral-400 mb-1.5">Email</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full h-11 px-3.5 text-sm bg-black border border-neutral-700 rounded-lg text-white focus:outline-none focus:border-[#00f3ff] transition-all"
              placeholder="you@example.com"
              required
            />
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
            disabled={isLoading}
            className="w-full h-11 bg-[#00f3ff] hover:shadow-[0_0_20px_rgba(0,243,255,0.3)] disabled:bg-neutral-800 disabled:text-neutral-500 disabled:cursor-not-allowed disabled:shadow-none text-black font-medium rounded-lg transition-all flex items-center justify-center gap-2"
          >
            {isLoading ? (
              <>
                <LoaderIcon className="w-4 h-4" />
                Sending...
              </>
            ) : (
              "Send Reset Link"
            )}
          </button>

          {/* Back to Login */}
          <p className="text-center text-neutral-500 text-sm pt-2">
            Remember your password?{" "}
            <Link href="/login" className="text-[#00f3ff] hover:underline">
              Sign in
            </Link>
          </p>
        </form>
      </div>
    </div>
  );
}

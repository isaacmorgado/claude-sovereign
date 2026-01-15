"use client";

import { useState, useEffect, Suspense } from "react";
import { useSearchParams } from "next/navigation";
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

function ResetPasswordForm() {
  const searchParams = useSearchParams();
  const token = searchParams.get("token");

  const [formData, setFormData] = useState({
    password: "",
    confirmPassword: "",
  });
  const [error, setError] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);

  useEffect(() => {
    if (!token) {
      setError("Invalid or missing reset token. Please request a new password reset.");
    }
  }, [token]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    if (!token) {
      setError("Invalid or missing reset token");
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

    setIsLoading(true);

    try {
      await api.resetPassword(token, formData.password);
      setIsSuccess(true);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to reset password");
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
          <h1 className="text-2xl font-semibold text-white mb-2">Password Reset</h1>
          <p className="text-neutral-400 mb-6">
            Your password has been successfully reset. You can now log in with your new password.
          </p>
          <Link
            href="/login"
            className="inline-block w-full h-11 bg-[#00f3ff] hover:shadow-[0_0_20px_rgba(0,243,255,0.3)] text-black font-medium rounded-lg transition-all leading-[44px]"
          >
            Go to Login
          </Link>
        </div>
      </div>
    );
  }

  if (!token) {
    return (
      <div className="min-h-screen flex flex-col items-center justify-center bg-black px-4">
        <div className="w-full max-w-sm text-center">
          <h1 className="text-2xl font-semibold text-white mb-4">Invalid Link</h1>
          <p className="text-neutral-400 mb-6">
            This password reset link is invalid or has expired.
            Please request a new one.
          </p>
          <Link
            href="/forgot-password"
            className="inline-block w-full h-11 bg-[#00f3ff] hover:shadow-[0_0_20px_rgba(0,243,255,0.3)] text-black font-medium rounded-lg transition-all leading-[44px]"
          >
            Request New Link
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
            Set New Password
          </h1>
          <p className="text-sm text-neutral-400 text-center">
            Enter your new password below
          </p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          {/* Password */}
          <div>
            <label className="block text-sm text-neutral-400 mb-1.5">New Password</label>
            <input
              type="password"
              value={formData.password}
              onChange={(e) => setFormData({ ...formData, password: e.target.value })}
              className="w-full h-11 px-3.5 text-sm bg-black border border-neutral-700 rounded-lg text-white focus:outline-none focus:border-[#00f3ff] transition-all"
              placeholder="Minimum 8 characters"
              required
              minLength={8}
            />
            {formData.password && formData.password.length < 8 && (
              <p className="text-xs text-neutral-500 mt-1">Minimum 8 characters</p>
            )}
          </div>

          {/* Confirm Password */}
          <div>
            <label className="block text-sm text-neutral-400 mb-1.5">Confirm New Password</label>
            <input
              type="password"
              value={formData.confirmPassword}
              onChange={(e) => setFormData({ ...formData, confirmPassword: e.target.value })}
              className={`w-full h-11 px-3.5 text-sm bg-black border rounded-lg text-white focus:outline-none transition-all ${
                formData.confirmPassword && formData.password !== formData.confirmPassword
                  ? "border-red-500"
                  : "border-neutral-700 focus:border-[#00f3ff]"
              }`}
              placeholder="Re-enter your password"
              required
            />
            {formData.confirmPassword && formData.password !== formData.confirmPassword && (
              <p className="text-xs text-red-400 mt-1">Passwords do not match</p>
            )}
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
            disabled={isLoading || formData.password.length < 8 || formData.password !== formData.confirmPassword}
            className="w-full h-11 bg-[#00f3ff] hover:shadow-[0_0_20px_rgba(0,243,255,0.3)] disabled:bg-neutral-800 disabled:text-neutral-500 disabled:cursor-not-allowed disabled:shadow-none text-black font-medium rounded-lg transition-all flex items-center justify-center gap-2"
          >
            {isLoading ? (
              <>
                <LoaderIcon className="w-4 h-4" />
                Resetting...
              </>
            ) : (
              "Reset Password"
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

export default function ResetPasswordPage() {
  return (
    <Suspense fallback={
      <div className="min-h-screen flex items-center justify-center bg-black">
        <LoaderIcon className="w-8 h-8 text-[#00f3ff]" />
      </div>
    }>
      <ResetPasswordForm />
    </Suspense>
  );
}

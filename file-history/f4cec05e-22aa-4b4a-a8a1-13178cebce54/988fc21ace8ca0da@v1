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

function MailIcon({ className }: { className?: string }) {
  return (
    <svg className={className} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <rect x="2" y="4" width="20" height="16" rx="2" />
      <path d="M22 6L12 13L2 6" />
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

function VerifyEmailContent() {
  const searchParams = useSearchParams();
  const token = searchParams.get("token");

  const [isLoading, setIsLoading] = useState(true);
  const [isVerified, setIsVerified] = useState(false);
  const [error, setError] = useState("");
  const [verifiedEmail, setVerifiedEmail] = useState("");

  useEffect(() => {
    if (!token) {
      setIsLoading(false);
      setError("No verification token provided");
      return;
    }

    const verifyEmail = async () => {
      try {
        const response = await api.verifyEmail(token);
        setIsVerified(true);
        setVerifiedEmail(response.email);
      } catch (err) {
        setError(err instanceof Error ? err.message : "Failed to verify email");
      } finally {
        setIsLoading(false);
      }
    };

    verifyEmail();
  }, [token]);

  // Loading state
  if (isLoading) {
    return (
      <div className="min-h-screen flex flex-col items-center justify-center bg-black px-4">
        <div className="w-full max-w-sm text-center">
          <div className="flex justify-center mb-6">
            <div className="h-16 w-16 rounded-full bg-cyan-500/20 flex items-center justify-center">
              <MailIcon className="w-8 h-8 text-cyan-400" />
            </div>
          </div>
          <h1 className="text-2xl font-semibold text-white mb-4">Verifying Your Email</h1>
          <div className="flex items-center justify-center gap-2 text-neutral-400">
            <LoaderIcon className="w-5 h-5" />
            <span>Please wait...</span>
          </div>
        </div>
      </div>
    );
  }

  // Success state
  if (isVerified) {
    return (
      <div className="min-h-screen flex flex-col items-center justify-center bg-black px-4">
        <div className="w-full max-w-sm text-center">
          <div className="flex justify-center mb-6">
            <div className="h-16 w-16 rounded-full bg-green-500/20 flex items-center justify-center">
              <CheckIcon className="w-8 h-8 text-green-500" />
            </div>
          </div>
          <h1 className="text-2xl font-semibold text-white mb-2">Email Verified!</h1>
          <p className="text-neutral-400 mb-2">
            Your email has been successfully verified.
          </p>
          {verifiedEmail && (
            <p className="text-cyan-400 mb-6 text-sm">
              {verifiedEmail}
            </p>
          )}
          <div className="space-y-3">
            <Link
              href="/login"
              className="inline-block w-full h-11 bg-cyan-400 hover:shadow-[0_0_20px_rgba(34,211,238,0.3)] text-black font-medium rounded-lg transition-all leading-[44px]"
            >
              Continue to Login
            </Link>
            <Link
              href="/"
              className="inline-block w-full h-11 border border-neutral-700 hover:border-neutral-600 text-neutral-300 font-medium rounded-lg transition-all leading-[44px]"
            >
              Go to Homepage
            </Link>
          </div>
        </div>
      </div>
    );
  }

  // Error state
  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-black px-4">
      <div className="w-full max-w-sm text-center">
        <div className="flex justify-center mb-6">
          <div className="h-16 w-16 rounded-full bg-red-500/20 flex items-center justify-center">
            <XIcon className="w-8 h-8 text-red-500" />
          </div>
        </div>
        <h1 className="text-2xl font-semibold text-white mb-2">Verification Failed</h1>
        <p className="text-neutral-400 mb-6">
          {error || "This verification link is invalid or has expired."}
        </p>
        <div className="space-y-3">
          <Link
            href="/login"
            className="inline-block w-full h-11 bg-cyan-400 hover:shadow-[0_0_20px_rgba(34,211,238,0.3)] text-black font-medium rounded-lg transition-all leading-[44px]"
          >
            Go to Login
          </Link>
          <p className="text-sm text-neutral-500 pt-2">
            You can request a new verification email from your account settings after logging in.
          </p>
        </div>
      </div>
    </div>
  );
}

export default function VerifyEmailPage() {
  return (
    <Suspense fallback={
      <div className="min-h-screen flex items-center justify-center bg-black">
        <LoaderIcon className="w-8 h-8 text-cyan-400" />
      </div>
    }>
      <VerifyEmailContent />
    </Suspense>
  );
}

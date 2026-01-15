"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { Eye, EyeOff } from "lucide-react";
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

export default function LoginPage() {
  const router = useRouter();
  const [formData, setFormData] = useState({
    email: "",
    password: "",
  });
  const [error, setError] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    if (!formData.email || !formData.password) {
      setError("Please enter your email and password");
      return;
    }

    setIsLoading(true);

    try {
      const response = await api.login({
        email: formData.email,
        password: formData.password,
      });

      // Store token and redirect
      localStorage.setItem("auth_token", response.access_token);
      api.setToken(response.access_token);
      router.push("/gender");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Login failed");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-black px-4">
      <div className="w-full max-w-sm">
        {/* Logo and Header */}
        <div className="mb-10">
          <div className="flex justify-center mb-6">
            <div className="h-8 w-8 rounded bg-cyan-400/20 flex items-center justify-center">
              <span className="text-cyan-400 text-sm font-bold">L</span>
            </div>
          </div>
          <h1 className="text-2xl font-semibold tracking-tight text-center text-white mb-2">
            Sign in to LOOKSMAXX
          </h1>
          <p className="text-sm text-neutral-400 text-center">
            Enter your email and password to continue
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

          {/* Password */}
          <div>
            <div className="flex justify-between items-center mb-1.5">
              <label className="text-sm text-neutral-400">Password</label>
              <Link
                href="/forgot-password"
                className="text-xs text-cyan-400 hover:underline"
              >
                Forgot password?
              </Link>
            </div>
            <div className="relative">
              <input
                type={showPassword ? "text" : "password"}
                value={formData.password}
                onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                className="w-full h-11 px-3.5 pr-10 text-sm bg-black border border-neutral-700 rounded-lg text-white focus:outline-none focus:border-cyan-400 transition-all"
                placeholder="Enter your password"
                required
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-neutral-500 hover:text-neutral-300 transition-colors"
              >
                {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
              </button>
            </div>
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
            className="w-full h-11 bg-cyan-400 hover:shadow-[0_0_20px_rgba(34,211,238,0.3)] disabled:bg-neutral-800 disabled:text-neutral-500 disabled:cursor-not-allowed disabled:shadow-none text-black font-medium rounded-lg transition-all flex items-center justify-center gap-2"
          >
            {isLoading ? (
              <>
                <LoaderIcon className="w-4 h-4" />
                Signing in...
              </>
            ) : (
              "Sign In"
            )}
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

          {/* Create Account Link */}
          <p className="text-center text-neutral-500 text-sm pt-2">
            Don&apos;t have an account?{" "}
            <Link href="/signup" className="text-cyan-400 hover:underline">
              Sign up
            </Link>
          </p>
        </form>
      </div>
    </div>
  );
}

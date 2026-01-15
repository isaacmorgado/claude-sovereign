import type { Metadata } from "next";
import { Manrope } from "next/font/google";
import "./globals.css";
import { Providers } from "@/components/Providers";

const manrope = Manrope({
  subsets: ["latin"],
  variable: "--font-manrope",
  display: "swap",
});

export const metadata: Metadata = {
  title: "LOOKSMAXX - Advanced Facial Analysis",
  description: "Professional facial analysis platform powered by AI",
  openGraph: {
    title: "LOOKSMAXX - Advanced Facial Analysis",
    description: "Professional facial analysis platform powered by AI",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "LOOKSMAXX - Advanced Facial Analysis",
    description: "Professional facial analysis platform powered by AI",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={`${manrope.variable} font-sans antialiased`}>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}

import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";

// Proxy runs BEFORE every page/route request.
// Its job: refresh the Supabase auth token if it's expired.
// Without this, users would get randomly logged out when their
// token expires (default: 1 hour).

export async function proxy(request: NextRequest) {
  let supabaseResponse = NextResponse.next({
    request,
  });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll();
        },
        setAll(cookiesToSet) {
          // Update cookies on the request (for downstream server code)
          cookiesToSet.forEach(({ name, value }) =>
            request.cookies.set(name, value)
          );
          // Update cookies on the response (sent back to browser)
          supabaseResponse = NextResponse.next({ request });
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options)
          );
        },
      },
    }
  );

  // This is the key line — it refreshes the session if the token is expired.
  // IMPORTANT: Do NOT remove this line. Without it, auth breaks silently.
  await supabase.auth.getUser();

  return supabaseResponse;
}

// Tell Next.js which routes this proxy applies to.
// We exclude static files and images — they don't need auth checks.
export const config = {
  matcher: [
    "/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)",
  ],
};

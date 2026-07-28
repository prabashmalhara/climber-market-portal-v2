import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";
import Link from "next/link";

export default async function AdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const supabase = await createClient();

  // 1. Get current logged-in user
  const { data: { user }, error: authError } = await supabase.auth.getUser();
  if (authError || !user) {
    redirect("/login");
  }

  // 2. Fetch their profile from the public.users table to check their role
  const { data: profile } = await supabase
    .from("users")
    .select("role")
    .eq("id", user.id)
    .single();

  // 3. The Gatekeeper: If they aren't an admin, kick them back to the homepage
  if (!profile || profile.role !== "admin") {
    redirect("/");
  }

  // If they made it past the redirect, they are an admin!
  // Render the admin layout shell around the child pages.
  return (
    <div className="admin-layout">
      <aside className="admin-sidebar">
        <h2 className="admin-logo">🛡️ Admin Panel</h2>
        <nav className="admin-nav">
          <Link href="/admin" className="admin-nav-link">Dashboard</Link>
          <Link href="/admin/customers" className="admin-nav-link">Customers</Link>
          <Link href="/admin/orders" className="admin-nav-link">Manage Orders</Link>
          <Link href="/admin/devices" className="admin-nav-link">Manage Devices</Link>
          <Link href="/admin/registrations" className="admin-nav-link">Device Approvals</Link>
          <Link href="/admin/software" className="admin-nav-link">Software Uploads</Link>
        </nav>
        
        <div className="admin-nav-bottom">
          <Link href="/" className="admin-nav-link">&larr; Back to Shop</Link>
        </div>
      </aside>
      
      <main className="admin-main">
        {children}
      </main>
    </div>
  );
}

"use server";

import { createClient } from "@/lib/supabase/server";

export async function getDownloadUrl(packageId: string) {
  const supabase = await createClient();

  // 1. Verify user is logged in
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return { success: false, error: "Unauthorized" };

  // 2. Fetch the package metadata to get the file path.
  // CRITICAL: Our RLS policy automatically ensures the query will return NO DATA
  // if the customer doesn't have an approved device for this product!
  const { data: pkg, error: fetchError } = await supabase
    .from("software_packages")
    .select("file_url, name, version")
    .eq("id", packageId)
    .single();

  if (fetchError || !pkg) {
    return { success: false, error: "Package not found or you don't have access to it." };
  }

  // 3. Generate a signed URL that expires in 1 hour (3600 seconds)
  const { data: signedData, error: signError } = await supabase.storage
    .from("software_releases")
    .createSignedUrl(pkg.file_url, 3600, {
      download: `${pkg.name}_v${pkg.version}`.replace(/\s+/g, '_') // Suggest a filename for the download
    });

  if (signError || !signedData) {
    console.error("Signed URL error:", signError);
    return { success: false, error: "Failed to generate secure download link." };
  }

  return { success: true, signedUrl: signedData.signedUrl };
}

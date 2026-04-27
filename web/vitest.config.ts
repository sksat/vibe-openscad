import { getViteConfig } from "astro/config";

// getViteConfig wraps Vite with Astro's plugins so `.astro` components can
// be imported directly from tests (needed for Container API tests).
export default getViteConfig({
  test: {
    include: ["src/**/*.test.ts", "tests/**/*.test.ts"],
    environment: "node",
  },
});

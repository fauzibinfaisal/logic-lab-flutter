import { readFileSync } from "node:fs";

const source = readFileSync(new URL("../src/index.ts", import.meta.url), "utf8");
const documentation = readFileSync(new URL("../API.md", import.meta.url), "utf8");
const routePattern =
  /request\.method === "(GET|POST)"\s*&&\s*url\.pathname === "([^"]+)"/g;

const routes = [
  ...new Set(
    [...source.matchAll(routePattern)].map(
      ([, method, path]) => `${method} ${path}`,
    ),
  ),
];
const missingRoutes = routes.filter(
  (route) => !documentation.includes(`\`${route}\``),
);

if (missingRoutes.length > 0) {
  console.error("API.md is missing these Worker routes:");
  for (const route of missingRoutes) console.error(`- ${route}`);
  console.error("Update API.md in the same change as the endpoint.");
  process.exit(1);
}

console.log(`API.md documents all ${routes.length} Worker routes.`);

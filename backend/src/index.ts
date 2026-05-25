import { env } from './config/env.js';
import { app } from './app.js';

app.listen(env.PORT, () => {
  console.log(`[SERVER] Helfy API listening on http://localhost:${env.PORT}`);
  console.log(`[SERVER] Environment: ${env.NODE_ENV}`);
});
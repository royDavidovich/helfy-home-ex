import type { JwtPayload } from 'jsonwebtoken';

export interface AuthUser {
  id: number;
  role: 'customer' | 'admin';
}

declare global {
  namespace Express {
    interface Request {
      user?: AuthUser;
    }
  }
}
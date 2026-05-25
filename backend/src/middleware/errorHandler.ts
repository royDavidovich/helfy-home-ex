import type { Request, Response, NextFunction } from 'express';
import { AppError } from '../utils/AppError.js';

/**
 * Global error-handling middleware. MUST be mounted last on the Express app.
 * Translates AppError (and unexpected errors) into the standard API envelope.
 */
export const errorHandler = (
  err: unknown,
  _req: Request,
  res: Response,
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  _next: NextFunction,
): void => {
  if (err instanceof AppError) {
    res.status(err.httpStatus).json({
      success: false,
      error: err.message,
      code: err.code,
    });
    return;
  }

  // Unexpected error — log full details server-side, return generic message
  console.error('[Unhandled Error]', err);
  res.status(500).json({
    success: false,
    error: 'Internal server error',
    code: 'INTERNAL',
  });
};
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const apiRouter = require('./routes');
const { ApiError } = require('./lib/http');

const app = express();

app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

app.use('/api/v1', apiRouter);

app.use((req, _res, next) => {
  next(new ApiError(404, 'Route not found'));
});

app.use((err, req, res, _next) => {
  const status = err.status || 500;
  const payload = {
    error: status >= 500 ? 'INTERNAL_ERROR' : 'REQUEST_ERROR',
    message: err.message || 'Unexpected error',
    details: err.details || null,
    timestamp: new Date().toISOString(),
    path: req.originalUrl
  };
  if (status >= 500) {
    // eslint-disable-next-line no-console
    console.error(err);
  }
  res.status(status).json(payload);
});

module.exports = app;

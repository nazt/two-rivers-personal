# Lesson Learned: Progressive Chunking & Data Bucketing for Web3 DApps

**Date**: 2026-03-01
**Context**: FloodBoy Webapp Data Visualization

## The Problem
When building vanilla JS frontends that read directly from smart contracts (like Viem.js querying Jibchain RPCs), requesting large historical datasets (e.g., 200,000 blocks) over a single `getContractEvents` call invariably results in RPC timeouts or HTTP 429 Rate Limits.
Furthermore, dumping 7,000+ individual timestamped records straight into a lightweight browser charting library (Chart.js) freezes the UI, creating massive memory bloat and turning lines into illegible visual noise.

## The Solution
**1. RPC Request Chunking:**
Iterate over the blockchain history in defined block sizes (e.g., `1999` blocks per request). By dispatching sequential or tightly controlled parallel chunk requests, the RPC node complies easily without throwing errors. The application can immediately start rendering the "first" returned chunks, creating a progressive load experience that keeps the user engaged instead of staring at a blank screen.

**2. In-Memory Data Bucketing (Aggregation):**
Before passing raw time-series data to the chart renderer, aggregate it. 
Create an interval bucket (e.g., `15 * 60 * 1000` ms) and map each incoming `{ timestamp, value }` point into its corresponding bucket by using `Math.floor(timestamp / BUCKET_MS) * BUCKET_MS`. Keep a running sum and count for each bucket. Finally, convert the buckets back to an array of averages (`sum / count`). This compresses thousands of records into manageable, visually smooth datasets, shrinking memory consumption by up to 90%.

## Code Pattern
```javascript
const BUCKET_MS = 15 * 60 * 1000; // 15-Minute grouping
const buckets = new Map();

cachedEvents.forEach(evt => {
    const ts = Number(evt.args.timestamp) * 1000;
    const bucketTime = Math.floor(ts / BUCKET_MS) * BUCKET_MS;
    const val = processRawValue(evt.args.values[dataIndex], targetField.unit);
    
    if (!buckets.has(bucketTime)) buckets.set(bucketTime, { sum: 0, count: 0 });
    
    const b = buckets.get(bucketTime);
    b.sum += val;
    b.count += 1;
});

// Convert back to chart points
const points = Array.from(buckets.entries())
    .sort((a, b) => a[0] - b[0])
    .map(([time, data]) => ({ x: new Date(time), y: data.sum / data.count }));
```

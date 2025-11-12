// Service Worker for Project Drishti - TB Detection PWA
// Enables offline functionality and caching for optimal performance

const CACHE_NAME = 'drishti-tb-detector-v1.0.0';
const API_CACHE = 'drishti-api-cache-v1';

// Assets to cache for offline use
const ASSETS_TO_CACHE = [
  '/',
  '/index.html',
  '/manifest.json',
  '/flutter_service_worker.js',
  '/main.dart.js',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png',
  '/icons/Icon-maskable-192.png',
  '/icons/Icon-maskable-512.png',
  '/assets/FontManifest.json',
  '/assets/AssetManifest.json',
  '/assets/NOTICES',
  // Add TFLite model when available
  // '/assets/models/tb_detector.tflite',
];

// Install event - cache assets
self.addEventListener('install', (event) => {
  console.log('[Service Worker] Installing Service Worker...', event);
  
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('[Service Worker] Caching app shell');
        return cache.addAll(ASSETS_TO_CACHE);
      })
      .then(() => {
        console.log('[Service Worker] All assets cached');
        return self.skipWaiting();
      })
      .catch((error) => {
        console.error('[Service Worker] Caching failed:', error);
      })
  );
});

// Activate event - clean up old caches
self.addEventListener('activate', (event) => {
  console.log('[Service Worker] Activating Service Worker...', event);
  
  event.waitUntil(
    caches.keys()
      .then((cacheNames) => {
        return Promise.all(
          cacheNames.map((cacheName) => {
            if (cacheName !== CACHE_NAME && cacheName !== API_CACHE) {
              console.log('[Service Worker] Removing old cache:', cacheName);
              return caches.delete(cacheName);
            }
          })
        );
      })
      .then(() => {
        console.log('[Service Worker] Claiming clients');
        return self.clients.claim();
      })
  );
});

// Fetch event - serve from cache, fall back to network
self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);
  
  // Skip chrome extension requests
  if (url.protocol === 'chrome-extension:') {
    return;
  }
  
  // API requests - network first, cache fallback
  if (url.pathname.startsWith('/api/') || url.hostname === '127.0.0.1' || url.hostname === 'localhost') {
    event.respondWith(
      fetch(request)
        .then((response) => {
          // Clone response before caching
          const responseClone = response.clone();
          
          // Cache successful responses
          if (response.ok) {
            caches.open(API_CACHE).then((cache) => {
              cache.put(request, responseClone);
            });
          }
          
          return response;
        })
        .catch(() => {
          // Network failed, try cache
          return caches.match(request)
            .then((cachedResponse) => {
              if (cachedResponse) {
                console.log('[Service Worker] Serving API from cache:', request.url);
                return cachedResponse;
              }
              // Return offline response
              return new Response(
                JSON.stringify({
                  error: 'Network unavailable',
                  offline: true,
                  message: 'Please check your internet connection'
                }),
                {
                  status: 503,
                  headers: { 'Content-Type': 'application/json' }
                }
              );
            });
        })
    );
    return;
  }
  
  // App assets - cache first, network fallback
  event.respondWith(
    caches.match(request)
      .then((cachedResponse) => {
        if (cachedResponse) {
          console.log('[Service Worker] Serving from cache:', request.url);
          return cachedResponse;
        }
        
        // Not in cache, fetch from network
        return fetch(request)
          .then((response) => {
            // Don't cache non-successful responses
            if (!response || response.status !== 200 || response.type !== 'basic') {
              return response;
            }
            
            // Clone response
            const responseClone = response.clone();
            
            // Cache the new resource
            caches.open(CACHE_NAME).then((cache) => {
              cache.put(request, responseClone);
            });
            
            return response;
          })
          .catch((error) => {
            console.error('[Service Worker] Fetch failed:', error);
            
            // Return offline page for navigation requests
            if (request.mode === 'navigate') {
              return caches.match('/index.html');
            }
            
            return new Response('Network error', {
              status: 408,
              headers: { 'Content-Type': 'text/plain' }
            });
          });
      })
  );
});

// Message event - handle messages from client
self.addEventListener('message', (event) => {
  console.log('[Service Worker] Message received:', event.data);
  
  if (event.data.action === 'skipWaiting') {
    self.skipWaiting();
  }
  
  if (event.data.action === 'clearCache') {
    event.waitUntil(
      caches.keys().then((cacheNames) => {
        return Promise.all(
          cacheNames.map((cacheName) => {
            console.log('[Service Worker] Clearing cache:', cacheName);
            return caches.delete(cacheName);
          })
        );
      })
    );
  }
});

// Background sync for offline analysis results
self.addEventListener('sync', (event) => {
  console.log('[Service Worker] Background sync:', event.tag);
  
  if (event.tag === 'sync-analysis-results') {
    event.waitUntil(syncAnalysisResults());
  }
});

// Sync analysis results when back online
async function syncAnalysisResults() {
  try {
    // Get pending results from IndexedDB or localStorage
    const pendingResults = await getPendingResults();
    
    if (pendingResults && pendingResults.length > 0) {
      console.log('[Service Worker] Syncing', pendingResults.length, 'pending results');
      
      // Send to server
      for (const result of pendingResults) {
        await fetch('/api/sync-result', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(result)
        });
      }
      
      // Clear pending results
      await clearPendingResults();
      console.log('[Service Worker] Sync complete');
    }
  } catch (error) {
    console.error('[Service Worker] Sync failed:', error);
  }
}

// Placeholder functions (implement with IndexedDB)
async function getPendingResults() {
  // TODO: Implement IndexedDB retrieval
  return [];
}

async function clearPendingResults() {
  // TODO: Implement IndexedDB clearing
}

console.log('[Service Worker] Service Worker loaded successfully');

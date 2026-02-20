/**
 * EpiAlert Service Worker
 * Provides offline support and caching for the EpiAlert PWA
 */

const CACHE_NAME = 'epialert-v1';
const OFFLINE_URL = '/offline.html';

// Resources to cache immediately on install
const PRECACHE_RESOURCES = [
  '/',
  '/offline.html',
  '/Narrator/weekly_digest/',
  '/glossary',
  '/parents/',
  '/map/',
  '/assets/css/just-the-docs-default.css',
  '/assets/js/just-the-docs.js'
];

// Install event - cache essential resources
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      console.log('[SW] Precaching resources');
      return cache.addAll(PRECACHE_RESOURCES);
    })
  );
  self.skipWaiting();
});

// Activate event - clean up old caches
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames
          .filter((name) => name !== CACHE_NAME)
          .map((name) => {
            console.log('[SW] Deleting old cache:', name);
            return caches.delete(name);
          })
      );
    })
  );
  self.clients.claim();
});

// Fetch event - network first, fallback to cache
self.addEventListener('fetch', (event) => {
  // Skip non-GET requests
  if (event.request.method !== 'GET') return;

  // Skip cross-origin requests
  if (!event.request.url.startsWith(self.location.origin)) return;

  event.respondWith(
    fetch(event.request)
      .then((response) => {
        // Clone the response before caching
        const responseClone = response.clone();

        // Cache successful responses
        if (response.status === 200) {
          caches.open(CACHE_NAME).then((cache) => {
            cache.put(event.request, responseClone);
          });
        }

        return response;
      })
      .catch(() => {
        // Network failed, try cache
        return caches.match(event.request).then((cachedResponse) => {
          if (cachedResponse) {
            return cachedResponse;
          }

          // If the request is for a page, show offline page
          if (event.request.mode === 'navigate') {
            return caches.match(OFFLINE_URL);
          }

          // Return a simple error response for other resources
          return new Response('Offline', {
            status: 503,
            statusText: 'Service Unavailable'
          });
        });
      })
  );
});

// Handle push notifications (for future use)
self.addEventListener('push', (event) => {
  if (!event.data) return;

  const data = event.data.json();
  const options = {
    body: data.body || '有新的疫情更新',
    icon: '/assets/images/icon-192.png',
    badge: '/assets/images/badge-72.png',
    vibrate: [100, 50, 100],
    data: {
      url: data.url || '/'
    },
    actions: [
      { action: 'view', title: '查看' },
      { action: 'dismiss', title: '關閉' }
    ]
  };

  event.waitUntil(
    self.registration.showNotification(data.title || 'EpiAlert 疫情快訊', options)
  );
});

// Handle notification click
self.addEventListener('notificationclick', (event) => {
  event.notification.close();

  if (event.action === 'dismiss') return;

  const url = event.notification.data.url || '/';

  event.waitUntil(
    clients.matchAll({ type: 'window' }).then((clientList) => {
      // Focus existing window if available
      for (const client of clientList) {
        if (client.url === url && 'focus' in client) {
          return client.focus();
        }
      }
      // Open new window
      if (clients.openWindow) {
        return clients.openWindow(url);
      }
    })
  );
});

// Background sync for future offline form submissions
self.addEventListener('sync', (event) => {
  if (event.tag === 'sync-settings') {
    event.waitUntil(syncSettings());
  }
});

async function syncSettings() {
  // Placeholder for future offline settings sync
  console.log('[SW] Syncing settings...');
}

// Import the Flutter-generated service worker, then add share-target handling.
try {
  importScripts('/flutter_service_worker.js');
} catch (e) {
  console.warn('Could not import flutter_service_worker.js:', e);
}

self.addEventListener('install', function(event) {
  self.skipWaiting();
});

self.addEventListener('activate', function(event) {
  event.waitUntil(self.clients.claim());
});

self.addEventListener('fetch', function(event) {
  const url = new URL(event.request.url);
  if (url.pathname === '/share-target' && event.request.method === 'POST') {
    event.respondWith((async function() {
      try {
        const formData = await event.request.formData();
        const text = formData.get('text') || '';
        const encoded = encodeURIComponent(text);
        const openUrl = '/?shared=' + encoded;
        const clientsList = await self.clients.matchAll({ type: 'window', includeUncontrolled: true });
        if (clientsList && clientsList.length > 0) {
          const client = clientsList[0];
          client.navigate(openUrl);
          client.focus();
        } else {
          await self.clients.openWindow(openUrl);
        }
        return new Response('<!doctype html><html><body>Shared</body></html>', { headers: { 'Content-Type': 'text/html' } });
      } catch (e) {
        return new Response('Error', { status: 500 });
      }
    })());
  }
});

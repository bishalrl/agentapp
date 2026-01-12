# 🔧 Base URL Configuration Guide

## ⚠️ CRITICAL: Update Your Base URL

Your Flutter app is currently configured to use `http://localhost:5000/api`, which may not work if:
- Your server is running on a different machine
- You're testing on a physical device (not emulator)
- Your server is on a different network

---

## 📍 Step 1: Find Your Server IP Address

### Windows:
```bash
ipconfig
```
Look for **IPv4 Address** (e.g., `192.168.1.100`)

### Mac/Linux:
```bash
ifconfig
```
Look for **inet** address (e.g., `192.168.1.100`)

---

## 🧪 Step 2: Test Your Server

Before updating Flutter, test your server with cURL:

```bash
# Replace YOUR_IP with your actual IP address
curl http://YOUR_IP:5000/health

# Should return: {"status":"OK","timestamp":"..."}
```

**If this fails:**
- Server is not running
- Server is not accessible from your network
- Firewall is blocking port 5000

---

## 🔧 Step 3: Update Flutter Base URL

### File to Edit:
`lib/core/constants/api_constants.dart`

### Current Configuration:
```dart
static const String baseUrl = 'http://localhost:5000/api';
```

### Update to Your Server IP:
```dart
// Replace YOUR_IP with your actual IP address
static const String baseUrl = 'http://YOUR_IP:5000/api';

// Example:
static const String baseUrl = 'http://192.168.1.100:5000/api';
```

---

## ✅ Step 4: Verify Configuration

After updating, the app will:
1. ✅ Show the base URL in debug logs
2. ✅ Detect parking pages automatically
3. ✅ Show clear error messages if URL is wrong
4. ✅ Prevent following redirects to parking pages

---

## 🚨 Common Issues

### Issue 1: "Got HTML response instead of JSON"
**Solution:** Base URL is wrong. Update `ApiConstants.baseUrl` to your server IP.

### Issue 2: "Connection refused"
**Solution:** 
- Server is not running
- Wrong IP address
- Firewall blocking connection

### Issue 3: "Redirected to parking page"
**Solution:** The domain redirects to a parking page. Use IP address instead of domain.

---

## 📱 Testing on Physical Device

If testing on a physical device (not emulator):

1. **Make sure device and server are on same network**
2. **Use server's local IP** (not `localhost` or `127.0.0.1`)
3. **Example:**
   ```dart
   static const String baseUrl = 'http://192.168.1.100:5000/api';
   ```

---

## 🌐 Production Setup

For production, use your actual server domain:

```dart
static const String baseUrl = 'https://your-actual-server.com/api';
```

**Make sure:**
- Server is properly deployed
- Domain is configured correctly
- SSL certificate is valid
- No redirects to parking pages

---

## 🔍 Debug Logging

The app now logs:
- Base URL being used
- Full request URL
- Response type (JSON vs HTML)
- Redirect locations

Check console logs to verify the correct URL is being used.

---

## ⚡ Quick Fix

1. Find your IP: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
2. Test server: `curl http://YOUR_IP:5000/health`
3. Update Flutter: Change `baseUrl` in `api_constants.dart`
4. Restart app and test!

---

**Remember:** Always use the same URL that works in cURL!



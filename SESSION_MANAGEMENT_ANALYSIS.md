# Session Management Analysis & Implementation

## Current State Analysis

### ✅ What's Working
1. **Token Storage**: Tokens are stored securely using `FlutterSecureStorage`
2. **Token Retrieval**: `GetStoredToken` use case retrieves tokens from storage
3. **401 Detection**: `ApiClient` detects 401 status codes and throws `AuthenticationException`
4. **Error Handling**: Repositories catch `AuthenticationException` and return `AuthenticationFailure`

### ❌ Issues Found

1. **No Automatic Token Clearing**: When token expires (401), the token remains in storage
2. **No Automatic Logout**: Users stay logged in even after token expiration
3. **No Automatic Redirect**: Only some pages (Dashboard, Booking) manually redirect to login
4. **Inconsistent Handling**: Different pages handle auth errors differently
5. **No Global Handler**: Each repository handles 401 individually
6. **No Token Refresh**: No mechanism to refresh expired tokens
7. **No Token Expiration Check**: Tokens are used without checking expiration before API calls

## Implementation Plan

### Phase 1: Centralized Session Manager ✅
- Created `SessionManager` singleton
- Handles automatic logout on 401
- Clears token from storage
- Redirects to login page

### Phase 2: Global 401 Handler ✅
- Updated `ApiClient` to trigger `SessionManager` on 401
- Updated `MultipartClient` to trigger `SessionManager` on 401
- Prevents duplicate logout attempts

### Phase 3: Repository Updates (In Progress)
- Update all repositories to use `SessionManager` when catching `AuthenticationException`
- Ensure consistent error messages

### Phase 4: Token Expiration Checking (Future Enhancement)
- Add JWT token parsing to check expiration
- Proactively clear expired tokens before API calls
- Show warning before token expires

## Files Modified

### Created
1. `lib/core/session/session_manager.dart` - Centralized session management
2. `lib/core/utils/auth_error_handler.dart` - Auth error utility
3. `lib/features/authentication/domain/usecases/clear_token.dart` - Clear token use case

### Updated
1. `lib/core/network/api_client.dart` - Global 401 handler
2. `lib/core/network/multipart_client.dart` - Global 401 handler
3. `lib/core/injection/injection.dart` - Registered `ClearToken`
4. `lib/main.dart` - Initialize `SessionManager`
5. `lib/features/dashboard/data/repositories/dashboard_repository_impl.dart` - Use SessionManager
6. `lib/features/profile/data/repositories/profile_repository_impl.dart` - Use SessionManager
7. `lib/features/booking/data/repositories/booking_repository_impl.dart` - Use SessionManager

## How It Works Now

### Flow on 401 Error:
1. **API Call Returns 401**
   - `ApiClient` or `MultipartClient` detects 401 status
   - Triggers `SessionManager().handleAuthenticationError()`

2. **Session Manager Actions**:
   - Checks if already logging out (prevents duplicates)
   - Clears token from secure storage using `ClearToken`
   - Logs out user using `Logout` use case
   - Navigates to `/login` page

3. **User Experience**:
   - User sees error message briefly
   - Automatically redirected to login page
   - Token is cleared, user must login again

### Benefits:
- ✅ **Automatic**: No manual intervention needed
- ✅ **Consistent**: Same behavior across all features
- ✅ **Secure**: Token is immediately cleared
- ✅ **User-Friendly**: Clear redirect to login

## Remaining Tasks

### High Priority
- [ ] Update all remaining repositories to use SessionManager
- [ ] Test token expiration scenarios
- [ ] Ensure navigation works correctly from all pages

### Medium Priority
- [ ] Add JWT token expiration checking
- [ ] Add token refresh mechanism (if API supports it)
- [ ] Add session timeout warning

### Low Priority
- [ ] Add session activity tracking
- [ ] Add automatic token refresh before expiration
- [ ] Add biometric authentication option

## Testing Checklist

- [ ] Test 401 error from API call
- [ ] Verify token is cleared from storage
- [ ] Verify user is redirected to login
- [ ] Test from different pages (Dashboard, Profile, Booking, etc.)
- [ ] Test multiple simultaneous 401 errors (should only logout once)
- [ ] Test navigation after logout
- [ ] Test login after token expiration

## Notes

- SessionManager uses singleton pattern for global access
- Prevents duplicate logout attempts with `_isLoggingOut` flag
- Uses `router.go('/login')` to clear navigation stack
- All repositories should catch `AuthenticationException` and trigger SessionManager

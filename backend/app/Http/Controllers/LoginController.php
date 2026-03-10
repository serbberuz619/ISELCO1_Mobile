<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use App\Models\UserModel;

class LoginController extends Controller
{
     public function login(Request $request)
{
    $request->validate([
        'email'    => 'required|email',
        'password' => 'required|string'
    ]);

    // 🔎 Check email exists
    $user = UserModel::where('Email', $request->email)->first();

    if (!$user) {
        return response()->json([
            'success' => false,
            'type'    => 'EMAIL_NOT_FOUND',
            'message' => 'Email and password do not match our records.'
        ], 404);
    }

    // 🔐 BIOMETRIC LOGIN (skip password check)
    if ($request->password === 'BIOMETRIC_LOGIN') {

        if ($user->Biometric_enable != 1) {
            return response()->json([
                'success' => false,
                'type'    => 'BIOMETRIC_NOT_ENABLED',
                'message' => 'Biometric login is not enabled for this account.'
            ], 403);
        }

    } else {

        // 🔑 NORMAL PASSWORD CHECK
        if (!Hash::check($request->password, $user->Password)) {
            return response()->json([
                'success' => false,
                'type'    => 'INVALID_PASSWORD',
                'message' => 'Email and password do not match our records.'
            ], 401);
        }
    }
  // ⏳ Verification check
    if ($user->Verification_status !== 'APPROVED') {
        return response()->json([
            'success' => false,
            'type'    => 'VERIFICATION_PENDING',
            'message' => 'Your account has not been verified by the CWO. Please wait for approval.'
        ], 403);
    }
    // 🚫 Account status check
    if ($user->Status !== 'ACTIVE') {
        return response()->json([
            'success' => false,
            'type'    => 'ACCOUNT_SUSPENDED',
            'message' => 'Your account has been suspended. Please go to the nearest branch to update your account.'
        ], 403);
    }

  

    // ✅ Login success
    $token = $user->createToken('mobile_app_token')->plainTextToken;

    return response()->json([
        'success' => true,
        'message' => 'Login successful.',
        'token'   => $token,
        'user'    => [
            'user_id'            => $user->User_id,
            'fullname'           => $user->Fullname,
            'email'              => $user->Email,
            'status'             => $user->Status,
            'verification_status'=> $user->Verification_status,
            'biometric_enabled'  => $user->Biometric_enable
        ]
    ]);
}

    // 🔐 TOGGLE BIOMETRIC LOGIN WITH PASSWORD CONFIRMATION
    public function toggleBiometric(Request $request)
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized.'
            ], 401);
        }

        $request->validate([
            'enable'   => 'required|boolean',
            'password' => 'required_if:enable,true|string'
        ]);

        if ($request->enable) {
            // Check password if enabling
            if (!Hash::check($request->password, $user->Password)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Incorrect password.'
                ], 401);
            }
            $user->Biometric_enable = 1;
        } else {
            $user->Biometric_enable = 0;
        }

        $user->save();

        return response()->json([
            'success' => true,
            'message' => $request->enable ? 'Biometric login has been enabled successfully.' : 'Biometric login has been disabled.',
            'biometric_enabled' => $user->Biometric_enable
        ]);
    }

    // 🔑 CHANGE PASSWORD
    public function changePassword(Request $request)
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized.'
            ], 401);
        }

        $request->validate([
            'old_password' => 'required|string',
            'new_password' => 'required|string|min:8|different:old_password',
        ]);

        if (!Hash::check($request->old_password, $user->Password)) {
            return response()->json([
                'success' => false,
                'message' => 'Incorrect old password.'
            ], 401);
        }

        $user->Password = bcrypt($request->new_password);
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Password updated successfully.'
        ]);
    }
}

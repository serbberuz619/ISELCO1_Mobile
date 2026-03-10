<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Models\UserModel;

class UserController extends Controller
{
    public function store(Request $request)
{
    DB::beginTransaction();

    try {

        // 🔍 VALIDATION
        $validator = Validator::make($request->all(), [
            'fullname'        => 'required|string|max:255',
            'account_number'  => 'required|string|max:50',
            'phone_number'    => 'required|string|max:20|unique:tbl_user,Phone_number',
            'email'           => 'required|email|unique:tbl_user,Email',
            'password'        => 'required|string|min:8|confirmed',

            // 📍 LOCATION
            'town'            => 'required|string|max:150',
            'barangay'        => 'required|string|max:150',
            'sitio'           => 'nullable|string|max:150',

            // 🪪 ID Upload
            'file'            => 'required|file|mimes:jpg,jpeg,png,pdf|max:5120',

            // Google (optional if coming from Google signup)
            'google_id'       => 'nullable|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors'  => $validator->errors()
            ], 422);
        }

        // 📂 STORE FILE SECURELY (NOT PUBLIC)
        $filePath = $request->file('file')->store('user_uploads', 'public');

        // 👤 CREATE USER
        $user = UserModel::create([
            'Fullname'            => $request->fullname,
            'Account_number'      => $request->account_number,
            'Phone_number'        => $request->phone_number,
            'Email'               => $request->email,
            'Google_id'           => $request->google_id,
            'Password'            => bcrypt($request->password),

            'Town'                => $request->town,
            'Barangay'            => $request->barangay,
            'Sitio'               => $request->sitio,

            'Upload_path'         => $filePath,


        ]);

        DB::commit();

        return response()->json([
            'success' => true,
            'message' => 'Registration submitted. Awaiting admin approval.',
        ], 201);

    } catch (\Throwable $e) {

        DB::rollBack();

        return response()->json([
            'success' => false,
            'message' => 'Server error',
            'error'   => $e->getMessage()
        ], 500);
    }
}
public function checkEmail(Request $request)
{
    $request->validate([
        'email' => 'required|email'
    ]);
    $exists = UserModel::where('Email', $request->email)->exists();

    return response()->json([
        'exists' => $exists
    ]);
}
}

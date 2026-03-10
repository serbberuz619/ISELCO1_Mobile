<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class TestController extends Controller
{
    /**
     * Isang simpleng API endpoint na nagre-return ng mensahe.
     * Ito ay pwedeng tawagin ng Vue Frontend at Flutter Mobile App.
     */
    public function getMessage()
    {
        // Ito ang JSON response na ipapadala natin sa mga clients (Vue / Flutter).
        // Evade spaghetti code: Panatilihing malinis at nakahiwalay ang logic sa controller na ito.
        return response()->json([
            'status' => 'success',
            'message' => 'Hello galing sa Laravel Backend!',
            'data' => [
                'project_name' => 'ISELCO1_Mobile',
                'description' => 'Laravel API is working perfectly.'
            ]
        ], 200);
    }
}

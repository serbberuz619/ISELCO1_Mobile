<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\TownsModel;
use App\Models\BarangayModel;

class TownAndBarangayController extends Controller
{
     public function getTowns()
    {
        $towns = TownsModel::orderBy('Town_name')
            ->get([
                'Town_id as id',
                'Town_name as townName'
            ]);

        return response()->json([
            'success' => true,
            'data' => $towns
        ]);
    }

    // ===============================
    // 🏘️ GET BARANGAYS BY TOWN (URL PARAM)
    // ===============================
    public function getBarangays($town_id)
    {
        if (!TownsModel::where('Town_id', $town_id)->exists()) {
            return response()->json([
                'success' => false,
                'message' => 'Town not found.'
            ], 404);
        }

        $barangays = BarangayModel::where('Town_id', $town_id)
            ->orderBy('Barangay_name')
            ->get([
                'Barangay_id as id',
                'Barangay_name as barangayName'
            ]);

        return response()->json([
            'success' => true,
            'data' => $barangays
        ]);
    }
}

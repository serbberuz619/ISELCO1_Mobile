<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Management;

/**
 * Controller para humawak sa pagkuha ng management data.
 */
class ManagementController extends Controller
{
    /**
     * Kunin ang lahat ng management personnel.
     */
    public function index()
    {
        try {
            // Kunin ang mga record galing sa tbl_management
            $managementList = Management::all();

            return response()->json([
                'success' => true,
                'data' => $managementList
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => "Nagkaroon ng problema sa pagkuha ng management directory. Error: " . $e->getMessage()
            ], 500);
        }
    }
}

<?php

namespace App\Http\Controllers;

use App\Models\BranchOffice;
use Illuminate\Http\Request;

class BranchController extends Controller
{
    // Get all branch offices
    public function index()
    {
        $branches = BranchOffice::all();
        
        return response()->json([
            'success' => true,
            'data' => $branches
        ]);
    }

    // Get specific branch office
    public function show($b_id)
    {
        $branch = BranchOffice::find($b_id);

        if (!$branch) {
            return response()->json([
                'success' => false,
                'message' => 'Branch office not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $branch
        ]);
    }
}

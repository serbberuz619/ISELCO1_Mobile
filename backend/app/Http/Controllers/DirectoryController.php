<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Directory;

/**
 * Controller para humawak sa pagkuha ng directory data.
 * I-handle nito ang paghihiwalay sa Board of Directors at Management.
 */
class DirectoryController extends Controller
{
    /**
     * Kunin ang mga tao sa directory base sa kategorya (halimbawa: board, management)
     */
    public function getByCategory($category)
    {
        try {
            // Kunin ang mga record galing sa tbl_directories kung saan ang category ay parehas sa hinihingi
            $directories = Directory::where('category', $category)->get();

            return response()->json([
                'success' => true,
                'data' => $directories
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => "Nagkaroon ng problema sa pagkuha ng directory. Error: " . $e->getMessage()
            ], 500);
        }
    }
}

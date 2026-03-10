<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Contact;

/**
 * Controller para humawak sa logic na kukuha ng contact hotlines.
 * Ito ang konektado sa mga API requests galing Mobile/Frontend.
 */
class ContactController extends Controller
{
    /**
     * Kunin ang lahat ng contact records mula sa database at i-return sa JSON format.
     */
    public function index()
    {
        try {
            // Kunin ang lahat na mga linyang nasa "tbl_contact"
            $contacts = Contact::all();

            // Mag-return ng JSON response pabalik sa user app
            return response()->json([
                'success' => true,
                'data' => $contacts
            ], 200);

        } catch (\Exception $e) {
            // Error handling sakaling may naging problema sa pag-query sa database
            return response()->json([
                'success' => false,
                'message' => "Nagkaroon ng problema sa pagkuha ng hotlines. Basehan ng error: " . $e->getMessage()
            ], 500);
        }
    }
}

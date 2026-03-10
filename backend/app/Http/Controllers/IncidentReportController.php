<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

use App\Models\IncidentReport;
use Illuminate\Support\Facades\Validator;

class IncidentReportController extends Controller
{
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'type_of_incident' => 'required|string|max:100',
            'is_iselco_pole' => 'nullable|string|max:10',
            'pole_number' => 'nullable|string|max:50',
            'specific_concern' => 'nullable|string|max:255',
            'report_type' => 'nullable|string|max:50',
            'account_number' => 'nullable|string|max:50',
            'town' => 'nullable|string|max:150',
            'barangay' => 'nullable|string|max:150',
            'sitio' => 'nullable|string|max:150',
            'remarks' => 'nullable|string',
            'landmarks' => 'nullable|string',
            'file' => 'nullable|file|mimes:jpg,jpeg,png,pdf|max:5120',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors'  => $validator->errors()
            ], 422);
        }

        $filePath = null;
        if ($request->hasFile('file')) {
            $filePath = $request->file('file')->store('incident_uploads', 'public');
        }

        // Check if user is authenticated (using Sanctum)
        $userId = null;
        if ($request->user()) {
            $userId = $request->user()->User_id;
        }

        try {
            $report = IncidentReport::create([
                'User_id' => $userId,
                'Type_of_incident' => $request->type_of_incident,
                'Is_iselco_pole' => $request->is_iselco_pole,
                'Pole_number' => $request->pole_number,
                'Specific_concern' => $request->specific_concern,
                'Report_type' => $request->report_type,
                'Account_number' => $request->account_number,
                'Town' => $request->town,
                'Barangay' => $request->barangay,
                'Sitio' => $request->sitio,
                'Remarks' => $request->remarks,
                'Landmarks' => $request->landmarks,
                'Upload_path' => $filePath,
                'Status' => 'PENDING',
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Incident reported successfully. Our team will look into it shortly.',
            ], 201);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to submit report',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}

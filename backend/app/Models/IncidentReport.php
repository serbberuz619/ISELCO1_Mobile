<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class IncidentReport extends Model
{
    protected $table = 'tbl_incident_reports';
    protected $primaryKey = 'Incident_id';

    protected $fillable = [
        'User_id',
        'Type_of_incident',
        'Is_iselco_pole',
        'Pole_number',
        'Specific_concern',
        'Report_type',
        'Account_number',
        'Town',
        'Barangay',
        'Sitio',
        'Remarks',
        'Landmarks',
        'Upload_path',
        'Status'
    ];
}

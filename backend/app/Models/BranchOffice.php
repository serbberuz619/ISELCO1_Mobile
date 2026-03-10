<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class BranchOffice extends Model
{
    use HasFactory;

    protected $table = 'tbl_branchOffice';
    protected $primaryKey = 'b_id';
    public $timestamps = false; 

    protected $fillable = [
        'office_name',
        'longitude',
        'latitude'
    ];
}

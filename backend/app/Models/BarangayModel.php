<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class BarangayModel extends Model
{
    protected $table = 'tbl_barangay';
    protected $primaryKey = 'Barangay_id';

    const CREATED_AT = 'Created_at';
    const UPDATED_AT = 'Updated_at';

    protected $fillable = [
        'Town_id',
        'Barangay_name',
    ];

      public function town()
    {
        return $this->belongsTo(TownsModel::class, 'Town_id', 'Town_id');
    }
}

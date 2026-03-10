<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class TownsModel extends Model
{
    protected $table = 'tbl_towns';
    protected $primaryKey = 'Town_id';

    const CREATED_AT = 'Created_at';
    const UPDATED_AT = 'Updated_at';

    protected $fillable = [
        'Town_name',
        'Town_code',
    ];

       public function barangays()
    {
        return $this->hasMany(BarangayModel::class, 'Town_id', 'Town_id');
    }
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * Model para sa "tbl_management" na naglalaman ng impormasyon tungkol sa mga opisyal na management.
 */
class Management extends Model
{
    // Tukuyin ang table na gagamitin
    protected $table = 'tbl_management';

    // Mga column na pwede lagyan ng data
    protected $fillable = [
        'employee_name',
        'position',
        'department'
    ];
}

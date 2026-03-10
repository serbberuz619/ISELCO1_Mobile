<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * Model para sa "tbl_directories" kung saan nakalagay ang mga Board of Directors at Management.
 */
class Directory extends Model
{
    // Tukuyin ang table na gagamitin
    protected $table = 'tbl_directories';

    // Mga column na pwede lagyan ng data
    protected $fillable = [
        'director_name',
        'position',
        'area',
        'category'
    ];
}

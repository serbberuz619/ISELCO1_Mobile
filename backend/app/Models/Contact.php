<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * Model para mag-handle ng data patungkol sa mga contact details o hotlines.
 * Nakakabit ito sa "tbl_contact" table sa database.
 */
class Contact extends Model
{
    // Tukuyin ang table na gagamitin sa database
    protected $table = 'tbl_contact';

    // Tukuyin kung ano ang mga columns na pwedeng lagyan ng data
    protected $fillable = [
        'branch_office',
        'contact_no',
    ];
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

use Illuminate\Notifications\Notifiable;
use Illuminate\Database\Eloquent\SoftDeletes;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class UserModel extends Authenticatable
{

    use HasApiTokens, HasFactory, Notifiable, SoftDeletes;

    protected $table = 'tbl_user';
    protected $primaryKey = 'User_id';

    const CREATED_AT = 'Created_at';
    const UPDATED_AT = 'Updated_at';
        public $timestamps = true;

    protected $fillable = [
        'Fullname',
        'Account_number',
        'Town',
        'Barangay',
        'Sitio',
        'Phone_number',
        'Email',
        'Google_id',
        'Password',
        'Verification_status',
        'Status',
        'Role',
        'Upload_path',
        'Biometric_enable',
        'Remember_token',
        'Verified_by',
        'Verified_at',
    ];

    protected $hidden = [
        'Password',
        'Remember_token',
    ];


     protected function casts(): array
    {
        return [
            'Password' => 'hashed',
            'Biometric_enable' => 'boolean',
        ];
    }

    public function getAuthPasswordName()
    {
        return 'Password';
    }
}

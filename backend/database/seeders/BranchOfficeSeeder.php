<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class BranchOfficeSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        DB::table('tbl_branchOffice')->insert([
            ['office_name' => 'Cabatuan Branch', 'latitude' => 16.9246, 'longitude' => 121.6441],
            ['office_name' => 'Ilagan Branch', 'latitude' => 17.1364, 'longitude' => 121.8906],
            ['office_name' => 'Roxas Branch', 'latitude' => 17.1132, 'longitude' => 121.6119],
            ['office_name' => 'San Mateo Branch', 'latitude' => 16.8833, 'longitude' => 121.5833]
        ]);
    }
}

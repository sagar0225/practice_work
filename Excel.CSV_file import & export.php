------------------------(Model)---------------------------

*Student Model:


 use HasFactory;
    protected $table ='students';
    protected $fillable = ['name','email','mobile '];
	
-----------------------------------------------------------------------------------

---------------------(Service file)----------------------------------------------
*studentService:


namespace App\Services;
use Exception;
use App\Models\Student;
use App\Http\Controllers\StudentController;
use Illuminate\Support\Facades\DB;
use Symfony\Component\Console\Input\Input;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Facades\Excel;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Storage;

public function exportStudentsToCSV()
    {
        $students = Student::all();

        $csvHeader = ['id', 'name', 'email', 'created At', 'updated At'];
        $csvData = [$csvHeader];

        foreach ($students as $student) {
            $csvData[] = [
                $student->id,
                $student->name,
                $student->email,
                $student->created_at,
                $student->updated_at,
            ];
        }

        $csvContent = implode(PHP_EOL, array_map(function ($row) {
            return implode(',', $row);
        }, $csvData));

        $filePath = 'exports/students.csv';

        Storage::put($filePath, $csvContent);

        return $filePath;
    }

-----------------------------------------------------------------------------------------------------

---------------------------(controller )-------------------------------------------------------------------------
*StudentController


use Illuminate\Http\Request;
use App\Models\Student;
use App\Services\StudentService;
use Maatwebsite\Excel\Facades\Excel;
use App\Exports\TableDataExport;
use Maatwebsite\Excel\Concerns\FromCollection;



    public function exportStudents()
    {
        $filePath = $this->studentService->exportStudentsToCSV();

        return response()->download(storage_path("app/{$filePath}"))
            ->deleteFileAfterSend(true);
    }
	
--------------------------------------------------------------------

--------------------------(Route)-------------------------------------

Route::get('export', [StudentController::class, 'exportStudents']);
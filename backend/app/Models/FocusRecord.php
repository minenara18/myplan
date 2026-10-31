<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Carbon;

/**
 * @property int $id
 * @property int $user_id
 * @property int|null $task_id
 * @property Carbon $mulai
 * @property int $durasi_menit
 * @property Carbon|null $created_at
 * @property Carbon|null $updated_at
 */
class FocusRecord extends Model
{
    /** @use HasFactory<\Database\Factories\FocusRecordFactory> */
    use HasFactory;

    protected $fillable = ['task_id', 'mulai', 'durasi_menit'];

    protected $casts = [
        'mulai' => 'datetime',
    ];

    /** @return BelongsTo<User, $this> */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /** @return BelongsTo<Task, $this> */
    public function task(): BelongsTo
    {
        return $this->belongsTo(Task::class);
    }
}

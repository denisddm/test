<?php

/**
 * В SPL уже есть класс SPLFileObject, который реализует SeekableIterator, поэтому ниже - просто изобретение велосипеда :)
 */
class FileSeekableIterator implements SeekableIterator
{
    const READ_BUFFER_SIZE  = 1;

    /** @var bool|resource  */
    private $file;

    /**
     * @param string $fileName
     * @throws Exception
     */
    public function __construct($fileName)
    {
        $this->file = fopen($fileName, 'r');

        if ($this->file === false) {
            throw new Exception('Failed to open file');
        }
    }

    /**
     * @param int $position
     */
    public function seek($position)
    {
        fseek($this->file, $position);
    }


    public function next()
    {
        fseek($this->file, self::READ_BUFFER_SIZE, SEEK_CUR);
    }

    /**
     * @return bool|mixed|string
     */
    public function current()
    {
        $v = fread($this->file, self::READ_BUFFER_SIZE);

        fseek($this->file, -1*self::READ_BUFFER_SIZE, SEEK_CUR);

        return $v;
    }

    /**
     * @return bool|int|mixed
     */
    public function key()
    {
        return ftell($this->file);
    }

    /**
     * @return bool
     */
    public function valid()
    {
        return !feof($this->file);
    }

    public function rewind()
    {
        fseek($this->file, 0);
    }
}


